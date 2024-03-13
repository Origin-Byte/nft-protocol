import * as critbitU64 from "./critbit-u64/structs";
import {StructClassLoader} from "../_framework/loader";

export function registerClasses(loader: StructClassLoader) {
    loader.register(critbitU64.CritbitTree);
    loader.register(critbitU64.InternalNode);
    loader.register(critbitU64.Leaf);
}
