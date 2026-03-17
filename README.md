# Rema Run

Et norsk top-down speedrunning-spill laget av medieelever ved Glemmen VGS, Fredrikstad.

## Spill det
**[Spill på itch.io](https://itch.io)** *(link oppdateres etter publisering)*

## Utvikling

### Krav
- [Godot 4.3](https://godotengine.org/download)
- Git

### Kom i gang
```bash
git clone https://github.com/stephanteig/rema-run-godot
# Åpne Godot 4 → Import → velg prosjektmappen
```

### Bygge til web
1. Åpne Godot → Project → Export → Web
2. Klikk "Export Project" → velg `builds/index.html`
3. Push til `main` → GitHub Actions deployer automatisk til itch.io

## itch.io oppsett
Legg til disse GitHub Secrets:
- `BUTLER_CREDENTIALS` — itch.io API-nøkkel fra https://itch.io/user/settings/api-keys
- `ITCH_USERNAME` — ditt itch.io brukernavn

## Lisenser
- Spillkode: MIT
- Kenney assets: CC0 (https://kenney.nl)
- Cozy People: Ikke-kommersiell (shubibubi.itch.io)
