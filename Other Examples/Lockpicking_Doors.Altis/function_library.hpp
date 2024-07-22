class CfgFunctions {

    class pizza {

        class util_functions {
            file = "functions\utility";

            class format_number;
        };

        class action_functions {
            file = "functions\actions";

            class lockpick;
        };

        class handler_functions {
            file = "functions\handlers";

            class handler_actions;
            class handler_keydown;
            class handler_keyup;
            class initEventHandlers;
        };


        class generic_functions {
            file = "functions\generic";

            class findTargetSelection;
        };

        class hud_functions {
            file = "hud\functions";

            class hud_lockpick;
        };
    };
};
