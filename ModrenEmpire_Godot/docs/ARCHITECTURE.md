# Modren Empire Architecture

Godot 4, Android-first, offline-capable. Core simulation is separated from UI: Game.gd owns state and simulation; Economy owns valuation/elasticity; SaveSystem owns versioned persistence; Network owns LAN sessions; BankAdapter exposes a future external bank boundary; Director owns Game Director controls.

The current bank is virtual/in-game only. No real money, payment processing, blockchain, or financial account is created.
