local composer = require("composer")

local options =
{
    effect = "fade",
    time = 200,
    params = {
        sampleVar1 = "my sample variable",
        sampleVar2 = "another sample variable"
    }
}


composer.gotoScene( "Scenes.mainmenu", options )