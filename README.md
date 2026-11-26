# klingtech/homebrew-tools

Homebrew formulas for Klingtech operator tools.

## klingbot-station

The Klingbot factory station, which Fleet's Factory page connects to for flashing and finishing Klingbots.
Install it from **Fleet → Factory → Install station**: the command it shows carries a ten-minute download token,
because the kit itself is served only to signed-in operators.

```bash
HOMEBREW_KLINGBOT_TOKEN=<token> brew install klingtech/tools/klingbot-station
klingbot-station
```

The formula holds only the kit's URL and sha256. It is updated by pull requests from the station-kit release in
`klingtech/klingsense-hw`; do not edit it by hand.
