import XMonad hiding (Tall)
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.LayoutHints
import XMonad.Layout.ResizableTile
import XMonad.Layout.Spiral
import XMonad.Layout.SimpleFloat
import XMonad.Layout.Tabbed
import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Util.Run(spawnPipe)
import XMonad.Actions.CycleWS
import Graphics.X11.ExtraTypes.XF86

import System.Exit
import System.IO
import Data.Monoid

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

main = do
    --xmproc <- spawnPipe "xmobar /home/lars/.xmonad/xmobar.sh"
    xmproc <- spawnPipe "xmobar ~/.xmonad/rcfiles/.xmobarrc2"
    --spawn "xmobar"
    xmonad $ withUrgencyHook NoUrgencyHook
           $ defaultConfig {
                terminal           = "urxvt",
                modMask            = mod4Mask,
                workspaces         = ["1:Terms", "2:Web", "3:Code", "4:Chat", "5:Rdp", "6", "7", "8:Torrents", "9:Music"],
                normalBorderColor  = "#333333",
                focusedBorderColor = "#3399cc",
                manageHook         = myManageHook,
                keys               = myKeys,
                mouseBindings      = myMouseBindings,
                layoutHook         = myLayout,
                logHook            = dynamicLogWithPP $ xmobarPP { 
                                         ppOutput = hPutStrLn xmproc,
                                         ppTitle = xmobarColor "green" "" . shorten 50
                                     }
    }

myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $

    [ ((modMask              , xK_Return   ), spawn $ XMonad.terminal conf)
--    , ((modMask .|. shiftMask, xK_c        ), kill)
    , ((modMask .|. shiftMask, xK_c     ), return()) -- %! Close the focused window
    , ((modMask              , xK_F4     ), kill) -- %! Close the focused window
    , ((modMask              , xK_space    ), sendMessage NextLayout)
    , ((modMask .|. shiftMask, xK_space    ), setLayout $ XMonad.layoutHook conf)
    , ((modMask              , xK_n        ), refresh)
    , ((modMask              , xK_Tab      ), windows W.focusDown)
    , ((modMask              , xK_j        ), windows W.focusDown)
    , ((modMask              , xK_k        ), windows W.focusUp)
    , ((modMask              , xK_m        ), windows W.focusMaster)
    , ((modMask .|. shiftMask, xK_Return   ), windows W.swapMaster)
    , ((modMask .|. shiftMask, xK_j        ), windows W.swapDown)
    , ((modMask .|. shiftMask, xK_k        ), windows W.swapUp)
    , ((modMask              , xK_h        ), sendMessage Shrink)
    , ((modMask              , xK_l        ), sendMessage Expand)
    , ((modMask .|. shiftMask, xK_h        ), sendMessage MirrorShrink)
    , ((modMask .|. shiftMask, xK_l        ), sendMessage MirrorExpand)
    , ((modMask              , xK_t        ), withFocused $ windows . W.sink)
    , ((modMask              , xK_comma    ), sendMessage (IncMasterN 1))
    , ((modMask              , xK_period   ), sendMessage (IncMasterN (-1)))
    , ((modMask .|. shiftMask, xK_q        ), io (exitWith ExitSuccess))
    , ((modMask              , xK_q        ), spawn "xmonad --recompile; xmonad --restart")
    , ((modMask              , xK_F2       ), shellPrompt defaultXPConfig)
    , ((modMask              , xK_n        ), spawn "sublime"            )
    , ((modMask .|. shiftMask, xK_n        ), spawn "madedit"            )
    , ((modMask              , xK_b        ), spawn "midori"             )
    , ((modMask              , xK_c        ), spawn "chrome"             )
    , ((modMask              , xK_f        ), spawn "firefox"             )
    , ((modMask              , xK_x        ), spawn "xchat"             )
    , ((modMask              , xK_g        ), spawn "grdesktop"          )
    , ((modMask              , xK_r        ), spawn "remmina"          )
    , ((0                    , 0x1008ff13  ), spawn "rexima vol +")
    , ((0                    , 0x1008ff11  ), spawn "rexima vol -")
--    , ((0                    , 0x1008ff12  ), spawn "/home/lars/.xmonad/scripts/aumix-mute-toogle.sh")
    , ((0                    , 0x1008ff16  ), spawn "mocp --prev")
    , ((0                    , 0x1008ff17  ), spawn "mocp --next")
    , ((0                    , 0x1008ff15  ), spawn "mocp --toggle-pause")
    , ((modMask              , xK_Print    ), spawn "scrot -e 'mv $f ~/Screenshots'")
    , ((modMask              , xK_F1 ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    , ((modMask .|. shiftMask, xK_F1 ), spawn ("echo \"" ++ help2 ++ "\" | xmessage -file -"))
    , ((modMask              , xK_Right    ), nextWS )
    , ((modMask              , xK_Left     ), prevWS )
    , ((modMask .|. shiftMask, xK_Right    ), shiftToNext )
    , ((modMask .|. shiftMask, xK_Left     ), shiftToPrev )
    ]
    ++

    [((m .|. modMask, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

    ++

    [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e] [0..]
--        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w
                                          >> windows W.shiftMaster))
    , ((modMask, button2), (\w -> focus w >> windows W.shiftMaster))
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w
                                          >> windows W.shiftMaster))
    ]

myLayout = avoidStruts $ layoutHints (tall ||| Mirror tall ||| spiral (6/7)  ||| Full ||| simpleTabbed ||| simpleFloat)
  where
     tall = ResizableTall nmaster delta ratio []
     nmaster = 1
     delta   = 3/100
     ratio   = 1/2

myManageHook :: ManageHook
myManageHook = composeAll
    [ className =? "grdesktop"    --> doShift "5:Rdp"
    , className =? "Remmina"    --> doShift "5:Rdp"
    , className =? "Chrome" --> doShift "2:Web"
    , className =? "Firefox" --> doShift "2:Web"
    , className =? "Midori" --> doShift "2:Web"
    , className =? "Sublime_text" --> doShift "3:Code"
    , className =? "Madedit" --> doShift "3:Code"
    , className =? "Transmission-gtk" --> doShift "8:Torrents"
    , className =? "Xchat" --> doShift "4:Chat"]

-- | A copy of My keybindings in simple textual tabular format.
help :: String
help = unlines ["My modifier key is 'win'. Mykeybindings:",
    "",
    "mod+Return              Launch terminal",
    "mod+F4                  Close the focused window",
    "mod+space               NextLayout",
    "mod+Shift+space         setLayout",
    "mod+n                   refresh",
    "mod+Tab                 windows W.focusDown",
    "mod+j                   windows W.focusDown",
    "mod+k                   windows W.focusUp",
    "mod+m                   windows W.focusMaster",
    "mod+Shift+Return        windows W.swapMaster",
    "mod+Shift+j             windows W.swapDown",
    "mod+Shift+k             windows W.swapUp",
    "mod+h                   sendMessage Shrink",
    "mod+l                   sendMessage Expand",
    "mod+Shift+h             sendMessage MirrorShrink",
    "mod+Shift+l             sendMessage MirrorExpand",
    "mod+t                   withFocused $ windows . W.sink",
    "mod+comma               sendMessage (IncMasterN 1)",
    "mod+period              sendMessage (IncMasterN (-1)",
    "mod+Shift+q             Exit xmonad",
    "mod+q                   recompile and restart xmonad",
    "mod+F2                  dmrun",
    "mod+n                   Sublime Text",
    "mod+Shift+n             Madedit",
    "mod+b                   Midori",
    "mod+c                   Chromeium",
    "mod+f                   Firefox",
    "mod+x                   Xchat",
    "mod+g                   Grdesktop",
    "mod+PrintScreen         Screenshot",
    "mod+F1                  help - Custom keybindings",
    "mod+Shift+F1            help2 - Standard keybindings",
    "mod+RightArrow          Switch to next WS",
    "mod+LeftArrow           Switch to previuos WS",
    "mod+Shift+RightArrow    Move windows to next WS",
    "mod+Shift+LeftArrow     Move window to previous WS",
    "",
    "To get the class name or title of an application for use in manageHook:",
    "Open the application.",
    "Enter the command xprop | grep WM_CLASS",
    "The class name is the second of the two quoted strings displayed, usually capitalized."]

-- | Finally, a copy of the default bindings in simple textual tabular format.
help2 :: String
help2 = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
