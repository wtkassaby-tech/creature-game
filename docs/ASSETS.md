# Assets register

Every asset that did not start in this project: Creator Store models, marketplace items, packs,
sounds, fonts and images. Any source is allowed (decisions log, 22 November 2026). Before an outside
asset goes into the place: its licence allows a commercial game; it has no real brands, IP or
characters from other games; every script inside it is removed or read line by line first.

| Date | Asset | Source and id | Creator | Licence | Scripts | Used for |
| --- | --- | --- | --- | --- | --- | --- |
| 22 Nov 2026 | Eight stand-in sounds for presses and battle moments: clickfast, electronicpingshort, snap, swordslash, kerplunk, bass, switch, victory | Built into Roblox itself (`rbxasset://sounds/...`); nothing uploaded | Roblox | Part of the Roblox engine, usable in any Roblox game | None | `src/client/Audio/Sfx.luau`, until the game has its own sounds |
| 23 Nov 2026 | Eight creature models (Sloshcalf, Mossmitt, Gorsling, Spadesnout, Stiltbark, Stumpwarden, Splashjack, Burlhorn): one mesh and one texture each | Made with Roblox Studio's model generator from our own written descriptions; ids in `src/content/CreatureModels.luau` | Generated in Ayrton's Studio (account 192240344) | Ours: generated from our own prompts inside Roblox | None (a mesh and a texture) | What each creature looks like, until the part meshes exist |
| 23 Nov 2026 | Twelve town models (Cottage, Shop, Healer, Tree, Pine, Bush, Lamp, Well; villagers Mentor, Rival, Shopkeeper, Tamer): one mesh and one texture each | Made with Roblox Studio's model generator from our own written descriptions; ids in `src/content/PropModels.luau` | Generated in Ayrton's Studio (account 192240344) | Ours: generated from our own prompts inside Roblox | None (a mesh and a texture) | Dressing the test map, until the real Greenwood map exists |
| 23 Nov 2026 | "Morning Birds 5 (SFX)", 74 seconds of birdsong | Roblox Creator Store audio, id 9116969794 | Pro Sound Effects | Roblox's licensed sound library: free to use in Roblox experiences | None (audio) | Town ambience, `src/client/Audio/Ambience.luau` |
| 23 Nov 2026 | Eight Dust Canyon creature models and three more villagers (Carer, GirlTamer, Grandmother) | Roblox Studio model generator, from our own descriptions; ids in `src/content/CreatureModels.luau` and `PropModels.luau` | Generated in Ayrton's Studio (account 192240344) | Ours: generated from our own prompts inside Roblox | None | Dust Canyon creatures; town keepers and tamers |
