"""QML Gauges MCP Server - X11 window inspection and screenshot capture."""

import base64
import json
import re
import subprocess
from pathlib import Path
from typing import Any

from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent, ImageContent


# Initialize MCP server
app = Server("qmlgauges")


@app.list_tools()
async def list_tools() -> list[Tool]:
    """List available QML Gauges tools."""
    return [
        Tool(
            name="qmlgauges_screenshot",
            description="Capture PNG screenshot of a QML Gauges window",
            inputSchema={
                "type": "object",
                "properties": {
                    "window": {
                        "type": "string",
                        "description": "Window name to capture (e.g., 'explorer', 'DevDash Gauges Explorer')",
                    }
                },
                "required": ["window"],
            },
        ),
        Tool(
            name="qmlgauges_list_windows",
            description="List available QML Gauges windows for screenshot capture",
            inputSchema={
                "type": "object",
                "properties": {},
                "required": [],
            },
        ),
    ]


def run_command(cmd: list[str]) -> tuple[str, int]:
    """Run a shell command and return (stdout, returncode)."""
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=False,
        )
        return result.stdout, result.returncode
    except FileNotFoundError:
        return f"Error: Command not found: {cmd[0]}", 1


def list_x11_windows() -> list[dict[str, Any]]:
    """List all X11 windows using xwininfo and wmctrl."""
    windows = []

    # Use wmctrl to list windows (more reliable than xwininfo -root -tree)
    stdout, returncode = run_command(["wmctrl", "-l", "-G"])
    if returncode != 0:
        # Fallback: try xwininfo -root -tree
        stdout, returncode = run_command(["xwininfo", "-root", "-tree"])
        if returncode != 0:
            return []

        # Parse xwininfo output
        # Format: "  0x1c0000a \"window name\": (\"app\" \"App\")  1920x1080+0+0  +0+0"
        pattern = r'^\s+(0x[0-9a-f]+)\s+"([^"]+)".*?(\d+)x(\d+)'
        for line in stdout.split('\n'):
            match = re.search(pattern, line)
            if match:
                window_id = match.group(1)
                title = match.group(2)
                width = int(match.group(3))
                height = int(match.group(4))

                # Skip root window and trivial windows
                if width > 100 and height > 100:
                    windows.append({
                        "id": window_id,
                        "title": title,
                        "width": width,
                        "height": height,
                    })
    else:
        # Parse wmctrl output
        # Format: "0x01c0000a  0 x y width height hostname title"
        for line in stdout.strip().split('\n'):
            if not line:
                continue
            parts = line.split(None, 7)
            if len(parts) >= 8:
                window_id = parts[0]
                x = int(parts[2])
                y = int(parts[3])
                width = int(parts[4])
                height = int(parts[5])
                title = parts[7]

                windows.append({
                    "id": window_id,
                    "title": title,
                    "width": width,
                    "height": height,
                    "x": x,
                    "y": y,
                })

    return windows


def find_window_by_name(name: str) -> str | None:
    """Find window ID by name (case-insensitive substring match)."""
    windows = list_x11_windows()
    name_lower = name.lower()

    # First try exact match
    for window in windows:
        if window["title"].lower() == name_lower:
            return window["id"]

    # Then try substring match
    for window in windows:
        if name_lower in window["title"].lower():
            return window["id"]

    return None


def capture_window_screenshot(window_id: str) -> bytes | None:
    """Capture screenshot of window using import (ImageMagick)."""
    try:
        # Use ImageMagick's import command
        # -window <id> captures specific window
        # png:- outputs PNG to stdout
        result = subprocess.run(
            ["import", "-window", window_id, "png:-"],
            capture_output=True,
            check=False,
        )

        if result.returncode != 0:
            # Fallback: try scrot with window ID
            # Save to temp file since scrot can't output to stdout
            import tempfile
            with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as tmp:
                tmp_path = tmp.name

            subprocess.run(
                ["scrot", "-u", "-o", tmp_path],
                check=False,
            )

            # Read the file
            tmp_file = Path(tmp_path)
            if tmp_file.exists():
                screenshot_data = tmp_file.read_bytes()
                tmp_file.unlink()
                return screenshot_data
            return None

        return result.stdout
    except FileNotFoundError:
        return None


@app.call_tool()
async def call_tool(name: str, arguments: Any) -> list[TextContent | ImageContent]:
    """Handle tool execution requests."""
    try:
        if name == "qmlgauges_list_windows":
            windows = list_x11_windows()

            # Filter for QML Gauges related windows
            qml_windows = [
                w for w in windows
                if any(keyword in w["title"].lower() for keyword in ["gauge", "explorer", "devdash", "qml"])
            ]

            return [
                TextContent(
                    type="text",
                    text=json.dumps({
                        "windows": qml_windows,
                        "total_count": len(qml_windows),
                    }, indent=2),
                )
            ]

        elif name == "qmlgauges_screenshot":
            window_name = arguments.get("window")
            if not window_name:
                return [
                    TextContent(
                        type="text",
                        text="Error: 'window' parameter is required",
                    )
                ]

            # Find window by name
            window_id = find_window_by_name(window_name)
            if not window_id:
                # List available windows for helpful error message
                windows = list_x11_windows()
                qml_windows = [
                    w for w in windows
                    if any(keyword in w["title"].lower() for keyword in ["gauge", "explorer", "devdash", "qml"])
                ]
                available = [w["title"] for w in qml_windows]

                return [
                    TextContent(
                        type="text",
                        text=f"Error: Window '{window_name}' not found.\n\nAvailable QML Gauges windows:\n" +
                             "\n".join(f"  - {title}" for title in available),
                    )
                ]

            # Capture screenshot
            screenshot_data = capture_window_screenshot(window_id)
            if not screenshot_data:
                return [
                    TextContent(
                        type="text",
                        text=f"Error: Failed to capture screenshot of window '{window_name}' (ID: {window_id}). "
                             "Make sure 'import' (ImageMagick) or 'scrot' is installed.",
                    )
                ]

            # Return image as base64-encoded PNG
            image_b64 = base64.b64encode(screenshot_data).decode("utf-8")

            return [
                ImageContent(
                    type="image",
                    data=image_b64,
                    mimeType="image/png",
                )
            ]

        else:
            return [
                TextContent(
                    type="text",
                    text=f"Unknown tool: {name}",
                )
            ]

    except Exception as e:
        return [
            TextContent(
                type="text",
                text=f"Error: {str(e)}",
            )
        ]


def main():
    """Run the QML Gauges MCP server."""
    import asyncio

    async def run():
        async with stdio_server() as (read_stream, write_stream):
            await app.run(read_stream, write_stream, app.create_initialization_options())

    asyncio.run(run())


if __name__ == "__main__":
    main()
