import * as package_1 from "../_dependencies/source/0x1/init";
import * as package_2 from "../_dependencies/source/0x2/init";
import * as package_70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa from "../allowlist/init";
import * as package_228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4 from "../authlist/init";
import * as package_5fb957b59e6b093c17eb3f0ca0a3e8762530244f39f738bd356dbdd43ed9230e from "../critbit/init";
import * as package_95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b from "../kiosk/init";
import * as package_c74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b from "../launchpad/init";
import * as package_4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a from "../liquidity-layer-v-1/init";
import * as package_bc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9 from "../nft-protocol/init";
import * as package_ed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32 from "../originmate/init";
import * as package_16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40 from "../permissions/init";
import * as package_9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb from "../pseudorandom/init";
import * as package_e2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43 from "../request/init";
import * as package_859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb from "../utils/init";
import {structClassLoaderSource as structClassLoader} from "./loader";

let initialized = false;

export function initLoaderIfNeeded() {
    if (initialized) {
        return
    };
    initialized = true;

    package_1.registerClasses(structClassLoader);
    package_2.registerClasses(structClassLoader);
    package_16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40.registerClasses(structClassLoader);
    package_228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4.registerClasses(structClassLoader);
    package_4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a.registerClasses(structClassLoader);
    package_5fb957b59e6b093c17eb3f0ca0a3e8762530244f39f738bd356dbdd43ed9230e.registerClasses(structClassLoader);
    package_70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa.registerClasses(structClassLoader);
    package_859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb.registerClasses(structClassLoader);
    package_95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b.registerClasses(structClassLoader);
    package_9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb.registerClasses(structClassLoader);
    package_bc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9.registerClasses(structClassLoader);
    package_c74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b.registerClasses(structClassLoader);
    package_e2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43.registerClasses(structClassLoader);
    package_ed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32.registerClasses(structClassLoader);
}
