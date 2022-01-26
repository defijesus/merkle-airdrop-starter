// Types
type IConfig = {
  flavor: String;
  decimals: number;
  airdrop: Record<string, number>;
};

// Config from generator
const config: IConfig = {
  "flavor": "ERC20",
  "decimals": 18,
  "airdrop": {
    "0xDe30040413b26d7Aa2B6Fc4761D80eb35Dcf97aD": 3,
    "0x9138DFD54596f4671f8ca8b4E9aD70095c81b5E9": 11,
    "0xb1120f07C94d7F2E16C7F50707A26A74bF0B12Ec": 1
  }
};

// Export config
export default config;
