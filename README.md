# SocialCoin Community Rewards Protocol (SCRP)

[![License: ISC](https://img.shields.io/badge/License-ISC-blue.svg)](https://opensource.org/licenses/ISC)
[![Clarity Version](https://img.shields.io/badge/Clarity-3.0-purple.svg)](https://clarity-lang.org/)
[![Stacks](https://img.shields.io/badge/Built%20on-Stacks-orange.svg)](https://stacks.org/)

## Overview

SocialCoin Community Rewards Protocol (SCRP) is a revolutionary decentralized protocol that enables community-driven wealth redistribution through automated reward mechanisms backed by cryptocurrency reserves. Built on the Stacks blockchain, SCRP transforms how communities share prosperity by creating a self-sustaining ecosystem where verified members receive periodic rewards from a collectively funded treasury.

## Key Features

- **🏛️ Democratic Governance**: Community-driven decision making for protocol parameters
- **✅ Verification System**: Sophisticated verification mechanisms to prevent abuse
- **⏰ Periodic Rewards**: Automated Universal Basic Income (UBI) distribution system
- **🛡️ Emergency Controls**: Built-in safety mechanisms for system stability
- **💰 Community Treasury**: Collectively funded reward pool
- **🔒 Security First**: Blockchain immutability ensures transparency and trust

## System Overview

The protocol operates on a simple yet powerful model:

1. **Community Registration**: Users register to join the community ecosystem
2. **Verification**: Contract owner verifies legitimate participants
3. **Treasury Funding**: Community members contribute to the shared treasury
4. **Reward Distribution**: Verified members claim periodic rewards (UBI)
5. **Governance**: Participants vote on protocol parameter changes

## Contract Architecture

### Core Components

#### State Variables

- **Treasury Balance**: Total funds available for distribution
- **Distribution Amount**: Reward amount per claim (default: 1 STX)
- **Distribution Interval**: Time between allowed claims (default: ~1 day)
- **Participant Count**: Total registered community members
- **Governance Counter**: Tracks proposal submissions

#### Data Structures

##### Participants Map

```clarity
{
  registered: bool,           // Registration status
  last-claim-height: uint,    // Last reward claim block
  total-claimed: uint,        // Lifetime rewards received
  verification-status: bool,  // Manual verification status
  join-height: uint,         // Registration block height
  claims-count: uint         // Total successful claims
}
```

##### Governance Proposals Map

```clarity
{
  proposer: principal,        // Proposal submitter
  proposal-type: string-ascii, // Parameter to modify
  proposed-value: uint,       // New proposed value
  votes-for: uint,           // Supporting votes
  votes-against: uint,       // Opposing votes
  status: string-ascii,      // Proposal status
  expiry-height: uint        // Voting deadline
}
```

## Data Flow

### Registration & Verification Flow

```
User Registration → Owner Verification → Eligibility for Rewards
```

### Reward Claim Flow

```
Eligibility Check → Cooldown Validation → Treasury Check → Reward Transfer → Record Update
```

### Governance Flow

```
Proposal Submission → Community Voting → Result Implementation
```

### Treasury Management Flow

```
Community Contributions → Treasury Pool → Reward Distribution → Balance Updates
```

## Core Functions

### Public Functions

#### Community Management

- `register()` - Register as a community member
- `verify-participant(principal)` - Verify a participant (owner only)
- `claim-ubi()` - Claim periodic community rewards

#### Treasury Operations

- `contribute()` - Contribute funds to the community treasury

#### Governance

- `submit-proposal(type, value)` - Submit governance proposals
- `vote(proposal-id, vote-for)` - Vote on active proposals

#### Emergency Controls

- `pause()` - Pause all reward claims (owner only)
- `unpause()` - Resume normal operations (owner only)

### Read-Only Functions

- `get-participant-info(principal)` - Get user details
- `get-treasury-balance()` - Get current treasury balance
- `get-proposal(uint)` - Get governance proposal details
- `get-distribution-info()` - Get distribution configuration

## Protocol Parameters

| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| Distribution Interval | 144 blocks (~1 day) | Time between reward claims |
| Distribution Amount | 1,000,000 µSTX (1 STX) | Reward per claim |
| Minimum Balance | 10,000,000 µSTX (10 STX) | Minimum treasury balance |
| Voting Period | 1440 blocks (~10 days) | Governance proposal duration |

## Security Features

### Error Handling

The contract implements comprehensive error codes for different failure scenarios:

- `u100`: Owner-only function access
- `u101`: Already registered
- `u102`: Not registered
- `u103`: Ineligible for rewards
- `u104`: Cooldown period active
- `u105`: Insufficient treasury funds
- `u106`: Invalid amount
- `u107`: Unauthorized access
- `u108`: Invalid proposal
- `u109`: Expired proposal
- `u110`: Invalid value

### Access Controls

- **Owner Functions**: Verification, emergency controls
- **Member Functions**: Registration, claiming, governance
- **Public Functions**: Treasury contributions, read-only operations

### Validation Mechanisms

- Cooldown period enforcement
- Treasury balance verification
- Proposal type validation
- Double-voting prevention
- Value bounds checking

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Node.js and npm for testing
- Stacks wallet for interaction

### Installation

1. Clone the repository:

```bash
git clone https://github.com/omoifo-augustine/social-coin.git
cd social-coin
```

2. Install dependencies:

```bash
npm install
```

3. Check contract syntax:

```bash
clarinet check
```

4. Run tests:

```bash
npm test
```

### Testing

The project includes comprehensive unit tests built with Vitest and the Clarinet SDK:

```bash
# Run all tests
npm test

# Run tests with coverage report
npm run test:report

# Watch mode for development
npm run test:watch
```

### Deployment

1. **Devnet Deployment**:

```bash
clarinet integrate
```

2. **Testnet Deployment**:
Configure your testnet settings in `settings/Testnet.toml` and deploy using Clarinet.

3. **Mainnet Deployment**:
Configure mainnet settings in `settings/Mainnet.toml` for production deployment.

## Usage Examples

### Register as a Community Member

```clarity
(contract-call? .social-coin register)
```

### Contribute to Treasury

```clarity
(contract-call? .social-coin contribute)
```

### Claim UBI Rewards

```clarity
(contract-call? .social-coin claim-ubi)
```

### Submit Governance Proposal

```clarity
(contract-call? .social-coin submit-proposal "distribution-amount" u2000000)
```

### Vote on Proposal

```clarity
(contract-call? .social-coin vote u1 true)
```

## Governance

The protocol features a democratic governance system where verified community members can:

1. **Submit Proposals** for changing:
   - Distribution amount
   - Distribution interval
   - Minimum treasury balance

2. **Vote on Proposals** with a simple yes/no mechanism

3. **Participate in Decision Making** that shapes the community's economic model

## Economic Model

### Treasury Sustainability

- Community-funded through voluntary contributions
- Minimum balance requirements ensure continuity
- Transparent balance tracking

### Fair Distribution

- Equal rewards for all verified members
- Cooldown periods prevent abuse
- Verification requirements ensure legitimacy

### Democratic Control

- Community governance over key parameters
- Transparent voting mechanisms
- Time-limited proposal periods

## Roadmap

- [ ] Multi-signature governance implementation
- [ ] Dynamic reward calculation based on treasury size
- [ ] Integration with additional DeFi protocols
- [ ] Mobile application for easier access
- [ ] Analytics dashboard for community insights

## Contributing

We welcome contributions to improve the SocialCoin Community Rewards Protocol. Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add comprehensive tests
5. Submit a pull request

## License

This project is licensed under the ISC License - see the [LICENSE](LICENSE) file for details.
