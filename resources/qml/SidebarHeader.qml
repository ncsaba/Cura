// Copyright (c) 2015 Ultimaker B.V.
// Cura is released under the terms of the AGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

import UM 1.2 as UM
import Cura 1.0 as Cura

import "Menus"

Column
{
    id: base;

    property int totalHeightHeader: childrenRect.height
    property int currentExtruderIndex:ExtruderManager.activeExtruderIndex;

    spacing: UM.Theme.getSize("default_margin").height

    signal showTooltip(Item item, point location, string text)
    signal hideTooltip()

    Row
    {
        id: machineSelectionRow
        height: UM.Theme.getSize("sidebar_setup").height

        anchors
        {
            left: parent.left
            leftMargin: UM.Theme.getSize("default_margin").width
            right: parent.right
            rightMargin: UM.Theme.getSize("default_margin").width
        }

        Label
        {
            id: machineSelectionLabel
            text: catalog.i18nc("@label:listbox", "Printer:");
            anchors.verticalCenter: parent.verticalCenter
            font: UM.Theme.getFont("default");
            color: UM.Theme.getColor("text");

            width: parent.width * 0.45 - UM.Theme.getSize("default_margin").width
        }

        ToolButton
        {
            id: machineSelection
            text: Cura.MachineManager.activeMachineName;

            height: UM.Theme.getSize("setting_control").height
            tooltip: Cura.MachineManager.activeMachineName
            anchors.verticalCenter: parent.verticalCenter
            style: UM.Theme.styles.sidebar_header_button

            width: parent.width * 0.55 + UM.Theme.getSize("default_margin").width

            menu: PrinterMenu { }
        }
    }

    ListView
    {
        id: extrudersList
        property var index: 0

        visible: machineExtruderCount.properties.value > 1
        height: UM.Theme.getSize("sidebar_header_mode_toggle").height

        boundsBehavior: Flickable.StopAtBounds

        anchors
        {
            left: parent.left
            leftMargin: UM.Theme.getSize("default_margin").width
            right: parent.right
            rightMargin: UM.Theme.getSize("default_margin").width
        }

        ExclusiveGroup { id: extruderMenuGroup; }

        orientation: ListView.Horizontal

        model: Cura.ExtrudersModel { id: extrudersModel; addGlobal: true }

        Connections
        {
            target: Cura.MachineManager
            onGlobalContainerChanged:
            {
                forceActiveFocus() // Changing focus applies the currently-being-typed values so it can change the displayed setting values.
                base.currentExtruderIndex = (machineExtruderCount.properties.value == 1) ? -1 : 0;
                ExtruderManager.setActiveExtruderIndex(base.currentExtruderIndex);
            }
        }

        delegate: Button
        {
            height: ListView.view.height
            width: ListView.view.width / extrudersModel.rowCount()

            text: model.name
            tooltip: model.name
            exclusiveGroup: extruderMenuGroup
            checkable: true
            checked: base.currentExtruderIndex == index

            onClicked:
            {
                forceActiveFocus() // Changing focus applies the currently-being-typed values so it can change the displayed setting values.
                base.currentExtruderIndex = index;
                ExtruderManager.setActiveExtruderIndex(index);
            }

            style: ButtonStyle
            {
                background: Rectangle
                {
                    border.width: UM.Theme.getSize("default_lining").width
                    border.color: control.checked ? UM.Theme.getColor("toggle_checked_border") :
                                        control.pressed ? UM.Theme.getColor("toggle_active_border") :
                                        control.hovered ? UM.Theme.getColor("toggle_hovered_border") : UM.Theme.getColor("toggle_unchecked_border")
                    color: control.checked ? UM.Theme.getColor("toggle_checked") :
                                control.pressed ? UM.Theme.getColor("toggle_active") :
                                control.hovered ? UM.Theme.getColor("toggle_hovered") : UM.Theme.getColor("toggle_unchecked")
                    Behavior on color { ColorAnimation { duration: 50; } }

                    Rectangle
                    {
                        id: swatch
                        visible: index > -1
                        height: UM.Theme.getSize("setting_control").height / 2
                        width: height
                        anchors.left: parent.left
                        anchors.leftMargin: (parent.height - height) / 2
                        anchors.verticalCenter: parent.verticalCenter

                        color: model.colour
                        border.width: UM.Theme.getSize("default_lining").width
                        border.color: UM.Theme.getColor("toggle_checked")
                    }

                    Label
                    {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: swatch.visible ? swatch.right : parent.left
                        anchors.leftMargin: swatch.visible ? UM.Theme.getSize("default_margin").width / 2 : UM.Theme.getSize("default_margin").width
                        anchors.right: parent.right
                        anchors.rightMargin: UM.Theme.getSize("default_margin").width / 2

                        color: control.checked ? UM.Theme.getColor("toggle_checked_text") :
                                    control.pressed ? UM.Theme.getColor("toggle_active_text") :
                                    control.hovered ? UM.Theme.getColor("toggle_hovered_text") : UM.Theme.getColor("toggle_unchecked_text")

                        font: UM.Theme.getFont("default")
                        text: control.text
                        elide: Text.ElideRight
                    }
                }
                label: Item { }
            }
        }
    }

    Row
    {
        id: variantRow

        height: UM.Theme.getSize("sidebar_setup").height
        visible: Cura.MachineManager.hasVariants || Cura.MachineManager.hasMaterials

        anchors
        {
            left: parent.left
            leftMargin: UM.Theme.getSize("default_margin").width
            right: parent.right
            rightMargin: UM.Theme.getSize("default_margin").width
        }

        Label
        {
            id: variantLabel
            text: (Cura.MachineManager.hasVariants && Cura.MachineManager.hasMaterials) ? catalog.i18nc("@label","Nozzle & Material:"):
                    Cura.MachineManager.hasVariants ? catalog.i18nc("@label","Nozzle:") : catalog.i18nc("@label","Material:");

            anchors.verticalCenter: parent.verticalCenter
            width: parent.width * 0.45 - UM.Theme.getSize("default_margin").width
            font: UM.Theme.getFont("default");
            color: UM.Theme.getColor("text");
        }

        Rectangle
        {
            anchors.verticalCenter: parent.verticalCenter

            width: parent.width * 0.55 + UM.Theme.getSize("default_margin").width
            height: UM.Theme.getSize("setting_control").height

            ToolButton {
                id: variantSelection
                text: Cura.MachineManager.activeVariantName
                tooltip: Cura.MachineManager.activeVariantName;
                visible: Cura.MachineManager.hasVariants
                enabled: !extrudersList.visible || base.currentExtruderIndex  > -1

                height: UM.Theme.getSize("setting_control").height
                width: materialSelection.visible ? (parent.width - UM.Theme.getSize("default_margin").width) / 2 : parent.width
                anchors.left: parent.left
                style: UM.Theme.styles.sidebar_header_button

                menu: NozzleMenu { }
            }

            ToolButton {
                id: materialSelection
                text: Cura.MachineManager.activeMaterialName
                tooltip: Cura.MachineManager.activeMaterialName
                visible: Cura.MachineManager.hasMaterials
                enabled: !extrudersList.visible || base.currentExtruderIndex  > -1

                height: UM.Theme.getSize("setting_control").height
                width: variantSelection.visible ? (parent.width - UM.Theme.getSize("default_margin").width) / 2 : parent.width
                anchors.right: parent.right
                style: UM.Theme.styles.sidebar_header_button

                menu: MaterialMenu { }
            }
        }
    }

    Row
    {
        id: globalProfileRow
        height: UM.Theme.getSize("sidebar_setup").height

        anchors
        {
            left: parent.left
            leftMargin: UM.Theme.getSize("default_margin").width
            right: parent.right
            rightMargin: UM.Theme.getSize("default_margin").width
        }


        Label
        {
            id: globalProfileLabel
            text: catalog.i18nc("@label","Profile:");
            width: parent.width * 0.45 - UM.Theme.getSize("default_margin").width
            font: UM.Theme.getFont("default");
            color: UM.Theme.getColor("text");
        }

        ToolButton
        {
            id: globalProfileSelection
            text: Cura.MachineManager.activeQualityName
            enabled: !extrudersList.visible || base.currentExtruderIndex  > -1

            width: parent.width * 0.55 + UM.Theme.getSize("default_margin").width
            height: UM.Theme.getSize("setting_control").height
            tooltip: Cura.MachineManager.activeQualityName
            style: UM.Theme.styles.sidebar_header_button

            menu: ProfileMenu { }

            UM.SimpleButton
            {
                id: customisedSettings

                visible: Cura.MachineManager.hasUserSettings
                height: parent.height * 0.6
                width: parent.height * 0.6

                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: UM.Theme.getSize("setting_preferences_button_margin").width - UM.Theme.getSize("default_margin").width

                color: hovered ? UM.Theme.getColor("setting_control_button_hover") : UM.Theme.getColor("setting_control_button");
                iconSource: UM.Theme.getIcon("star");

                onClicked: Cura.Actions.manageProfiles.trigger()
                onEntered:
                {
                    var content = catalog.i18nc("@tooltip","Some setting values are different from the values stored in the profile.\n\nClick to open the profile manager.")
                    base.showTooltip(globalProfileRow, Qt.point(0, globalProfileRow.height / 2),  content)
                }
                onExited: base.hideTooltip()
            }
        }
    }

    UM.SettingPropertyProvider
    {
        id: machineExtruderCount

        containerStackId: Cura.MachineManager.activeMachineId
        key: "machine_extruder_count"
        watchedProperties: [ "value" ]
        storeIndex: 0
    }

    UM.I18nCatalog { id: catalog; name:"cura" }
}
