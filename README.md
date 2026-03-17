# Rema Run 🏃‍♂️⚡

Et norsk top-down speedrunning-spill laget av medieelever ved Glemmen VGS, Fredrikstad.

> Kjøp energidrikk til deg og klassen — kom tilbake før pausen er over!

## Spill det
👉 **[Spill på itch.io](https://itch.io)** *(link oppdateres etter publisering)*

---

## Prosjektstruktur

```
rema-run-godot/
├── project.godot           ← Åpne dette i Godot 4
├── scenes/                 ← 9 .tscn scener
├── scripts/                ← 10 GDScript-filer
│   ├── GameState.gd        ← Autoload singleton (global timer, handleliste)
│   └── data/               ← Varer.gd + Karakterer.gd
├── assets/                 ← 45 PNG-filer
└── .github/workflows/      ← Auto-deploy til itch.io ved push
```

### Scene-rekkefølge
```
Boot → Hovedmeny → Klasserom → Utendørs → Butikk → Kasse → Tilbake → Seier/Tap
```

---

## 🖥️ Kom i gang på Windows-PC

```bash
git clone https://github.com/stephanteig/rema-run-godot
```

Åpne **Godot 4.3** → **Import** → velg `project.godot`

---

## 🚀 Publisere til itch.io (når du er klar)

Legg til to GitHub Secrets under **Settings → Secrets → Actions**:

| Secret | Verdi |
|---|---|
| `BUTLER_API_KEY` | API-nøkkel fra https://itch.io/user/settings/api-keys |
| `ITCH_USERNAME` | Ditt itch.io-brukernavn |

Deretter: hver gang du pusher til `main` → GitHub Actions bygger og deployer automatisk. 🎮

---

## 🤖 Guide for Claude — fortsett herfra

Når du fortsetter utviklingen med Claude Code, lim inn denne konteksten øverst i chatten:

```
Prosjekt: Rema Run v2 — Godot 4 (GDScript)
Repo: https://github.com/stephanteig/rema-run-godot
Motor: Godot 4.3, canvas 1280×720, Arcade physics
Språk: Alt på norsk (tekst, meldinger, UI)
Assets: 45 PNG-filer i assets/ (ingen programmatisk grafikk)
```

### Hva som er bygget
- ✅ **GameState.gd** — Autoload singleton med global 10-minutters timer, handleliste, powerups og personlig rekord (lagret i `user://saves.cfg`)
- ✅ **Boot.tscn** — Lasteskjerm ("Laster...") → Hovedmeny
- ✅ **MainMenu.gd** — Velg vanskelighetsgrad (vanlig/vanskelig) og karakter (Sondre/Kristine/????)
- ✅ **Classroom.gd** — Lærer sier "10 minutters pause!", 3 klassekamerater ber om varer, trykk E for å akseptere
- ✅ **Outdoor.gd** — Scrollende kart fra skolen til Rema. Vanlig: brorute. Vanskelig: dodge biler i 4 filer
- ✅ **Store.gd** — Stor butikk med kjøleskap, hyller og soner. Trykk E i riktig sone for å hente varer. Egg-og-reke event → meksikaner spawner
- ✅ **Checkout.gd** — Kassedialog, ID-sjekk med 33% sjanse (modifisert av karakter), ui_godkjent/ui_avvist
- ✅ **Return.gd** — Samme kart, tilbake til skolen. Timer løper fortsatt
- ✅ **WinScreen.gd** — Vis gjenværende tid, vareliste, personlig rekord
- ✅ **LoseScreen.gd** — Vis fail-grunn og tid igjen

### Hva som gjenstår / kan forbedres

**Prioritet 1 — Kjerne gameplay:**
- [ ] Walk-animasjon med `char_sondre_walk_sheet.png` (4 frames, 256×96px → `AnimatedSprite2D`)
- [ ] Kollisjonskart i butikk — spilleren kan gå gjennom vegger/hyller (trenger `StaticBody2D` for blokkerende tiles)
- [ ] Korrekt kamera-begrensning i butikken (kamera følger spiller, butikken er større enn skjermen)
- [ ] Mathias NPC har ingen walk-animasjon

**Prioritet 2 — Innhold:**
- [ ] Klasseromscene mangler ekte tilemap (bruker ColorRect nå)
- [ ] Utendørsscene mangler ekte tile-sprites (bruker ColorRect for vei/gress/fortau nå)
- [ ] Butikkscene bør bruke de faktiske tile-PNG-ene i stedet for ColorRect-fallbacks
- [ ] Legg til bakgrunnsmusikk og lydeffekter (Godot AudioStreamPlayer)
- [ ] Touch-kontroller / D-pad overlay for mobil

**Prioritet 3 — Polish:**
- [ ] Animerte taleballonger (tween inn/ut)
- [ ] Powerup-effektvisning på HUD (vis aktive powerups med ikon + nedtelling)
- [ ] Pause-meny (Escape-tast)
- [ ] Leaderboard (topp 10 lokalt i ConfigFile)

### Nøkkelfiler å kjenne til

| Fil | Hva den gjør |
|---|---|
| `scripts/GameState.gd` | Global tilstand — endre dette for nye spillvariabler |
| `scripts/data/Varer.gd` | Alle varenavn og kategori→asset-mapping |
| `scripts/data/Karakterer.gd` | Karakter-statistikk (hastighet, ID-sjekk-sjanse) |
| `scripts/Store.gd` | Butikk-layout og sone-logikk — her er mest gameplay |
| `scenes/*.tscn` | Minimale scene-filer — all logikk er i tilhørende .gd |

### Viktige konvensjoner
- **Alle tekster på norsk** — meldinger, knapper, labels, debug-output
- **Ingen programmatisk grafikk** — bruk alltid `load("res://assets/filnavn.png")`
- **GameState er autoload** — tilgjengelig som `GameState.variabel` overalt
- **Scenebytte:** `get_tree().change_scene_to_file("res://scenes/Filnavn.tscn")`
- **Input:** bruk `Input.is_physical_key_pressed(KEY_W)` + `Input.is_action_pressed("ui_up")` for å støtte både WASD og piltaster

---

## Bygge til web lokalt

1. Åpne Godot → **Project → Export**
2. Velg **Web**-preseten (allerede konfigurert i `export_presets.cfg`)
3. Klikk **Export Project** → velg `builds/index.html`
4. Test lokalt: `cd builds && python3 -m http.server 8080`

---

## Lisenser
- Spillkode: MIT
- Kenney assets: CC0 (https://kenney.nl)
- Cozy People: Ikke-kommersiell (shubibubi.itch.io)
