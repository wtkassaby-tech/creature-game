# Phone accessibility and UX audit (client)

Scope: `src/client/*`, read-only, 23 November 2026. Target view 874x402. Static read of the code (no Studio run), so sizes marked "check" need a capture. Roblox touch guidance: 44x44 px minimum; body text 14 px or more.

## Top fixes (do first)
1. No reduced-motion option anywhere (shake, hit-stop, flash, bars, auras, screen transition bars). Add one setting and gate them.
2. Lasso assist and slow mode have no player-facing control: the client only relays `SlowMode`/`ConnectionAssist` from the server (`Lasso/LassoPlayer.luau:14-15,48-49`).
3. Several touch targets are under 44 px: speed toggle 52x30, HUD buttons 112x40, friends cells 36x36.
4. Several signals are colour-only (HP bar, lasso tap stamps, STRONG/WEAK colour).
5. Text drops below 14 px in many places (pixel face 12-14, `UITextSizeConstraint` minimums of 7-8).

## Touch targets (minimum 44x44)
| Where | Size | Fix |
| --- | --- | --- |
| `BattleView/BattleView.luau:463` speed ">>" | 52x30 | 56x44 minimum; it sits at the right edge, mid-height, under the thumb. |
| `UI/HudStrip.luau:14,61` HUD buttons | 112x40; currency cells 96x40 | Raise buttons to 44 high (the strip is 54 tall, so it fits). |
| `Creatures/FriendsStrip.luau:46` | 36x36 cells | If tappable, 44x44; if display only, fine. |
| `Creatures/BreedStrip.luau:83,89` | 100x44, 70x44 | Height OK. Breed and Clear are close together: add 8 px spacing so the costly Breed is not hit by mistake. |
| `Story/StoryView.luau:326` | 200x48 | OK. |
| `BattleView/BattleView.luau:264,270`, `GiantView/GiantView.luau:172,178` | 44 high, 50 px pitch | OK at the limit. |
| `Creatures/CreatureCard.luau:150` | 22x22 disc | Display only, fine. |
| `UI/Kit.luau:293-313` `Kit.button` | height set by callers | Add a 44 px floor in `Kit.button` so a caller cannot go below. |

## Text sizes at 874x402
- `Kit.label` and `Kit.button` use `TextScaled` with `MinTextSize` 8 and 7 (`Kit.luau:143,310`). On a 402 px high screen a label in a small box silently shrinks to 7-8 px. Raise the minimum to 12 and let the box grow or wrap.
- Sub-14 px text: `BattleView/MoveButton.luau:52-53` (info 13, hint 12; STRONG/WEAK is the type-chart learning aid), `BattleView.luau:128` HP tag in a 28x14 box, `Creatures/DetailPanel.luau:127` (14), `Creatures/CreatureCard.luau` level 14 and team number 14, `Lasso/LassoView.luau:34` hint capped at 15.
- Pixel face at 12-14 px is hard to read: raise MoveButton info and hint to 14-16 and widen the band.
- Add a text size setting (small, normal, large) that scales `MaxTextSize` through `Kit.textSize`.

## Colour-only signals
- HP bars (`BattleView.luau:131,547`; `CreatureCard.luau:140`): the card shows no number. Add the number, or a low-health icon below 25 percent.
- Lasso (`LassoView.luau:53-100,193`): a green zone on tan rope; tap stamps white (hit) versus red (miss); a gold ring when over the green. Red/green clashes for colour-blind players. Add a striped zone, a tick or cross in the stamp, and a "NOW" word while over the green. The loop swelling 30 to 38 px is a good non-colour cue.
- `MoveButton.luau:60-71`: type has colour plus icon (good); STRONG/WEAK are words (good). Add an arrow glyph.
- Disabled buttons (`Kit.luau:330-343`) change colour and ink only; tapping gives no reason. Show a short line in the message box.
- Contrast: `Kit.COLOURS.textDim` (124,118,132) on cream (250,243,222) is about 3.6:1, under 4.5:1. Darken to about (96,90,104). `mutedInk` (140,134,140) on the muted face probably is under 3:1: check, since disabled battle moves must stay legible.

## Reduced motion
Nothing reads a setting. Gate these behind one `reducedMotion` flag (saved in the profile; Roblox has no system flag to read):
- Camera shake `BattleStage.luau:54,94-130` and hit-stop `:667`.
- White edge flash `BattleFx.luau:125-148` (snap to 0.25 transparency in 0.05 s). Also a photosensitivity point: replace with a soft fade when reduced.
- Screen transition bars `UI/Transition.luau`: use a cross-fade.
- Creature breath, aura hover and glow pulse (`ToyBody.luau`, `Aura.luau`), world people breathing and turning (`WorldLife.luau`), the Creatures button pulse (`CreaturesView.luau:274-`), lasso loop swell.
- Button hover and press scale (`Kit.luau:212-`) is small, fine to keep.

## Lasso assist and slow mode
- The server sends both flags and `LassoPlayer.begin` copies them, but there is no settings UI and no on-screen sign that assist is on (`Debug/TestPanel.luau:247` is debug only).
- Add Settings toggles: slow lasso, wider green, connection assist. Persist in the profile and send as intent only; the server stays authoritative (hard rule 1). Saving touches the profile, so it needs Ayrton's approval first.
- Show a small badge in `LassoView` while assist or slow is on.
- THROW is 62 high and full width (`LassoView.luau:113-117`): good for one hand. Also accept a tap anywhere on the panel.
- `roundTripMs` is 0 on the client (`LassoPlayer.luau:46`); the loop is driven by RenderStepped, so low-FPS phones see a jumpy loop. Keep the server judging on its own clock.

## Safe areas
- Good: `Kit.screen(..., safe)` uses `CoreUISafeInsets` with `IgnoreGuiInset` (`Kit.luau:94-107`), used by HUD, battle and dialogue.
- Check every `Kit.screen` call made without `safe` that holds buttons. Confirm the Battle gui is `safe`, since `LassoView` anchors 8 px from the bottom.
- Add 12-16 px of bottom margin for the iPhone home indicator on dialogue and lasso panels.

## One-handed reach
- Good: THROW is full width at the bottom; picker Back is the last row.
- Poor: the HUD (Creatures, Journal) is top right and needs a stretch; the speed toggle is mid-right.
- Add a handedness flag that mirrors the picker and speed toggle, and consider a bottom-corner Creatures shortcut.
- The battle picker is centred (0.28 to 0.72 width): fine for two thumbs.

## Loading and error states
- `ToyBody.luau:100-131,387,457` tracks loading and failed species, but a failed model shows nothing. Show a chunky placeholder in the type colour, with a retry.
- `SpeakerFace.luau:73-95` and `BattleView.luau:961` (`warn("Catch scene failed")`) report to the console only. Show a short on-screen line and make sure the battle cannot soft lock (Run must still work).
- `Shop/Prices.luau:13` price is `false` while in flight or failed: confirm the shop shows "..." or "Unavailable" and disables Buy.
- Net actions (`BuyItem`, `SetTeam`, `ReleaseCreature`, `RequestBreed`, `ExpandStable`) are fire and forget with no pending state. Disable the button for the round trip with a timeout message of about 5 s. Check Release has a confirm step.
- `CreaturesView.luau:421` `task.wait(1)` loop: check it ends when the screen closes.
- `ClientState.get()` can be nil (`WorldView.luau:305,326`) and callers return silently. Show "Loading your pals..." until the snapshot arrives, and a rejoin message after a timeout.
- No client message for a lost connection or failed data load.

## Other notes
- `Debug/TestPanel.luau` is in the client: gate or strip it before launch.
- Add a Settings screen: text size, reduced motion, lasso assist and slow, handedness, colour-blind-safe lasso palette.

## Suggested order
1. Settings screen and profile fields (needs approval, it touches saving).
2. `Kit.button` 44 px floor, label minimum 12 px, HUD and speed toggle sizes.
3. Lasso non-colour cues and an assist badge.
4. Loading and error states for models, shop and net actions.
5. Contrast change to `textDim`.
