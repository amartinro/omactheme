#!/usr/bin/env python3
"""Add a macOS-style hover close button to a cloned notification card.

Run against ~/.config/omarchy/plugins/<user>.notifications/components/
NotificationCard.qml after `omarchy plugin clone omarchy.notifications`.
Idempotent: a card that already carries the button is left untouched.

Anchors are the upstream card's own structure (the full-card MouseArea and the
mainColumn layout). If a future Omarchy rewrites that structure, this exits 1
with a clear message instead of shipping a silently unpatched card.
"""

import sys
from pathlib import Path

MARKER = "macOS-style close affordance"

IMPORT_ANCHOR = "import QtQuick.Layouts\n"
BLOCK_ANCHOR = "  ColumnLayout {\n    id: mainColumn\n"

GUTTER_MARKER = "reserves the top-left corner for the hover close button"
GUTTER_ANCHOR = "      Layout.leftMargin: Style.space(12)\n"
GUTTER_REPLACEMENT = (
    "      // Left gutter reserves the top-left corner for the hover close "
    "button\n"
    "      // (Style.space(6) margin + Style.space(20) circle) so the icon "
    "and text\n"
    "      // never sit under it.\n"
    "      Layout.leftMargin: Style.space(32)\n"
)

CLOSE_BUTTON = '''  // macOS-style close affordance: a small circle with an x, anchored to the
  // top-left corner, revealed only while the pointer is over the card. It sits
  // above the full-card MouseArea so a click dismisses this notification
  // instead of invoking its default action.
  Item {
    id: closeSlot
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.topMargin: Style.space(6)
    anchors.leftMargin: Style.space(6)
    width: Style.space(20)
    height: Style.space(20)
    z: 10
    // Gating visibility on opacity keeps the invisible hit area from eating
    // clicks over the icon slot while the card is not hovered.
    visible: opacity > 0
    opacity: root.hovered ? 1 : 0
    scale: root.hovered ? 1 : 0.85

    Behavior on opacity {
      NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
    }

    Behavior on scale {
      NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
    }

    Rectangle {
      anchors.fill: parent
      radius: width / 2
      // No hoverEnabled on closeArea: the card's own HoverHandler must keep
      // receiving hover (it pauses the lifetime countdown), so the button
      // styles from root.hovered plus press feedback only.
      color: Util.alpha(Color.notifications.text, closeArea.containsPress ? 0.30 : 0.16)
    }

    Shape {
      id: closeGlyph
      anchors.centerIn: parent
      width: Style.space(7)
      height: Style.space(7)
      preferredRendererType: Shape.CurveRenderer

      ShapePath {
        fillColor: "transparent"
        strokeColor: Color.notifications.text
        strokeStyle: ShapePath.SolidLine
        capStyle: ShapePath.RoundCap
        strokeWidth: Style.spaceReal(1.4)

        PathMove { x: 0; y: 0 }
        PathLine { x: closeGlyph.width; y: closeGlyph.height }
      }

      ShapePath {
        fillColor: "transparent"
        strokeColor: Color.notifications.text
        strokeStyle: ShapePath.SolidLine
        capStyle: ShapePath.RoundCap
        strokeWidth: Style.spaceReal(1.4)

        PathMove { x: closeGlyph.width; y: 0 }
        PathLine { x: 0; y: closeGlyph.height }
      }
    }

    MouseArea {
      id: closeArea
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      acceptedButtons: Qt.AllButtons
      onClicked: root.closeRequested()
    }
  }

'''


def fail(message: str) -> int:
    print(f"close-button: {message}", file=sys.stderr)
    return 1


def main() -> int:
    if len(sys.argv) != 2:
        return fail("usage: close-button.py <NotificationCard.qml>")

    path = Path(sys.argv[1])
    try:
        text = path.read_text()
    except OSError as exc:
        return fail(f"cannot read {path}: {exc}")

    changed = False

    if MARKER not in text:
        if IMPORT_ANCHOR not in text:
            return fail(f"{path}: upstream card no longer imports QtQuick.Layouts; "
                        "this Omarchy version needs a manual patch")
        if BLOCK_ANCHOR not in text:
            return fail(f"{path}: upstream card no longer has the mainColumn layout; "
                        "this Omarchy version needs a manual patch")

        if "import QtQuick.Shapes" not in text:
            text = text.replace(IMPORT_ANCHOR,
                                IMPORT_ANCHOR + "import QtQuick.Shapes\n", 1)

        # Declared after the full-card MouseArea and with a higher z, so the
        # button is above it in stacking order and consumes the click first.
        text = text.replace(BLOCK_ANCHOR, CLOSE_BUTTON + BLOCK_ANCHOR, 1)
        changed = True

    # The button lives in the card's top-left corner, so the content row must
    # leave that corner empty; otherwise the icon sits under the button.
    if GUTTER_MARKER not in text:
        if GUTTER_ANCHOR not in text:
            return fail(f"{path}: upstream card no longer insets the content row "
                        "with Style.space(12); this Omarchy version needs a "
                        "manual patch")
        text = text.replace(GUTTER_ANCHOR, GUTTER_REPLACEMENT, 1)
        changed = True

    if changed:
        path.write_text(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
