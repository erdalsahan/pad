# atlaspad/pad

## localnet/gelistirici ortami

### 1. bir pencerede localhost agi ayaga kaldir

```bash
pnpm run hardhat node --network hardhat
```

### 2. bir baska pencerede akilli kontratlari deploy et

```bash
pnpm run hardhat ignition deploy ./ignition/modules/AtlaspadDemo.ts --network localhost
pnpm run hardhat compile
```

### 3. deployment artifact'lari tasi

```bash
./move_stuff.sh
```

### frontend'i baslat

```bash
pnpm run dev -- --open
```
