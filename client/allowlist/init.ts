import * as allowlist from "./allowlist/structs";
import * as frozenPub from "./frozen-pub/structs";
import * as obAllowlist from "./ob-allowlist/structs";
import {StructClassLoader} from "../_framework/loader";

export function registerClasses(loader: StructClassLoader) {
    loader.register(allowlist.CollectionKey);
    loader.register(allowlist.ALLOWLIST);
    loader.register(allowlist.Allowlist);
    loader.register(allowlist.AllowlistOwnerCap);
    loader.register(frozenPub.FROZEN_PUB);
    loader.register(obAllowlist.OB_ALLOWLIST);
}
