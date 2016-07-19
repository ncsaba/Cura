// Copyright (c) 2015 Ultimaker B.V.
// Uranium is released under the terms of the AGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

import UM 1.2 as UM
import Cura 1.0 as Cura

ScrollView
{
    id: base;

    style: UM.Theme.styles.scrollview;
    flickableItem.flickableDirection: Flickable.VerticalFlick;

    property Action configureSettings;
    signal showTooltip(Item item, point location, string text);
    signal hideTooltip();

    ListView
    {
        id: contents
        spacing: UM.Theme.getSize("default_lining").height;
        cacheBuffer: 1000000;   // Set a large cache to effectively just cache every list item.

        model: UM.SettingDefinitionsModel {
            id: definitionsModel;
            containerId: Cura.MachineManager.activeDefinitionId
            visibilityHandler: UM.SettingPreferenceVisibilityHandler { }
            exclude: ["machine_settings"]
            expanded: Printer.expandedCategories
            onExpandedChanged: Printer.setExpandedCategories(expanded)

            filter: {}
        }

        delegate: Loader
        {
            id: delegate

            width: UM.Theme.getSize("sidebar").width;
            height: provider.properties.enabled == "True" ? UM.Theme.getSize("section").height : 0
            Behavior on height { NumberAnimation { duration: 100 } }
            opacity: provider.properties.enabled == "True" ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 100 } }
            enabled:
            {
                if(!ExtruderManager.activeExtruderStackId && ExtruderManager.extruderCount > 0)
                {
                    // disable all controls on the global tab, except categories
                    return model.type == "category"
                }
                return provider.properties.enabled == "True"
            }

            property var definition: model
            property var settingDefinitionsModel: definitionsModel
            property var propertyProvider: provider

            //Qt5.4.2 and earlier has a bug where this causes a crash: https://bugreports.qt.io/browse/QTBUG-35989
            //In addition, while it works for 5.5 and higher, the ordering of the actual combo box drop down changes,
            //causing nasty issues when selecting different options. So disable asynchronous loading of enum type completely.
            asynchronous: model.type != "enum" && model.type != "extruder"
            active: model.type != undefined

            source:
            {
                switch(model.type)
                {
                    case "int":
                        return "SettingTextField.qml"
                    case "float":
                        return "SettingTextField.qml"
                    case "enum":
                        return "SettingComboBox.qml"
                    case "extruder":
                        return "SettingExtruder.qml"
                    case "bool":
                        return "SettingCheckBox.qml"
                    case "str":
                        return "SettingTextField.qml"
                    case "category":
                        return "SettingCategory.qml"
                    default:
                        return "SettingUnknown.qml"
                }
            }

            UM.SettingPropertyProvider
            {
                id: provider

                containerStackId: ExtruderManager.activeExtruderStackId ? ExtruderManager.activeExtruderStackId : Cura.MachineManager.activeMachineId
                key: model.key ? model.key : ""
                watchedProperties: [ "value", "enabled", "state", "validationState", "settable_per_extruder" ]
                storeIndex: 0
            }

            Connections
            {
                target: item
                onContextMenuRequested: { contextMenu.key = model.key; contextMenu.popup() }
                onShowTooltip: base.showTooltip(delegate, { x: 0, y: delegate.height / 2 }, text)
                onHideTooltip: base.hideTooltip()
            }
        }

        UM.I18nCatalog { id: catalog; name: "uranium"; }

        add: Transition {
            SequentialAnimation {
                NumberAnimation { properties: "height"; from: 0; duration: 100 }
                NumberAnimation { properties: "opacity"; from: 0; duration: 100 }
            }
        }
        remove: Transition {
            SequentialAnimation {
                NumberAnimation { properties: "opacity"; to: 0; duration: 100 }
                NumberAnimation { properties: "height"; to: 0; duration: 100 }
            }
        }
        addDisplaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 100 }
        }
        removeDisplaced: Transition {
            SequentialAnimation {
                PauseAnimation { duration: 100; }
                NumberAnimation { properties: "x,y"; duration: 100 }
            }
        }

        Menu
        {
            id: contextMenu;

            property string key;

            MenuItem
            {
                //: Settings context menu action
                text: catalog.i18nc("@action:menu", "Hide this setting");
                onTriggered: definitionsModel.hide(contextMenu.key);
            }
            MenuItem
            {
                //: Settings context menu action
                text: catalog.i18nc("@action:menu", "Configure setting visiblity...");

                onTriggered: Cura.Actions.configureSettingVisibility.trigger(contextMenu);
            }
        }
    }
}
