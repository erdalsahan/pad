import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const INITIAL_OWNER = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";

const AtlaspadDemoModule = buildModule("AtlaspadDemoModule", (m) => {
	const apToken = m.contract("APToken", [INITIAL_OWNER]);

	return { apToken };
});

export default AtlaspadDemoModule;
