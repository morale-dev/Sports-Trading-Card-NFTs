# Sports Trading Card NFT Contract

A Clarity smart contract for minting and managing digital sports trading cards with player statistics and rarity tiers.

## Features

- Mint trading cards with complete player information and stats
- Four rarity levels: Common, Uncommon, Rare, Legendary
- Detailed player statistics tracking
- Team and position information
- Season-based card series organization
- Dynamic card value calculation
- Standard NFT trait compliance

## Contract Functions

### Public Functions
- `mint-sports-card`: Create a new sports card NFT with player stats
- `transfer`: Transfer card ownership
- `update-base-uri`: Update metadata base URI (owner only)

### Read-Only Functions
- `get-last-token-id`: Get the latest minted token ID
- `get-token-uri`: Get metadata URI for a card
- `get-owner`: Get current owner of a card
- `get-card-info`: Get card and player information
- `get-player-stats`: Get player statistics
- `get-rarity-name`: Convert rarity number to name
- `calculate-card-value`: Calculate card value based on rarity and performance

## Rarity Levels

1. Common (1) - Base value multiplier
2. Uncommon (2) - 2x value multiplier
3. Rare (3) - 3x value multiplier
4. Legendary (4) - 4x value multiplier

## Card Value System

Card values are calculated using:
- Base value (100) × rarity multiplier
- Performance bonus based on points and assists averages
- Final value = (Base × Rarity) + Performance Bonus

## Player Statistics

Each card tracks comprehensive player statistics:
- Games played in the season
- Points per game average
- Assists per game average
- Rebounds per game average
- Field goal percentage

## Usage

Call `mint-sports-card` with all required player information, statistics, and rarity level to create a new trading card NFT. The contract validates jersey numbers (0-99), field goal percentages (0-100%), and season years (must be after 2000).
