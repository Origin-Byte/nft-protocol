import * as critBit from "./crit-bit/structs";
import * as dynamicVector from "./dynamic-vector/structs";
import * as sizedVec from "./sized-vec/structs";
import * as utilsSupply from "./utils-supply/structs";
import * as utils from "./utils/structs";
import {StructClassLoader} from "../_framework/loader";

export function registerClasses(loader: StructClassLoader) {
    loader.register(utils.IsShared);
    loader.register(utils.Marker);
    loader.register(critBit.CritbitTree);
    loader.register(critBit.InternalNode);
    loader.register(critBit.Leaf);
    loader.register(dynamicVector.DynVec);
    loader.register(sizedVec.SizedVec);
    loader.register(utilsSupply.Supply);
}
