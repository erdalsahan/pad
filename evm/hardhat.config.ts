import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';

const config: HardhatUserConfig = {
	solidity: '0.8.24',
	networks: {
		hardhat: {
			chainId: 31337
		},

		running: {
			url: 'http://localhost:8545',
			chainId: 31337
		}
	}
};

export default config;
