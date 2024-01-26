import * as pseudorandom from "./pseudorandom/structs";
import {StructClassLoader} from "../_framework/loader";

export function registerClasses(loader: StructClassLoader) {
    loader.register(pseudorandom.Counter);
}
