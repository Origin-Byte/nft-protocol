import * as balances from "./balances/structs";
import * as bloomFilter from "./bloom-filter/structs";
import * as box from "./box/structs";
import * as critBitU64 from "./crit-bit-u64/structs";
import * as critBit from "./crit-bit/structs";
import * as escrowShared from "./escrow-shared/structs";
import * as escrow from "./escrow/structs";
import * as i128Type from "./i128-type/structs";
import * as i64Type from "./i64-type/structs";
import * as linearVesting from "./linear-vesting/structs";
import * as objectBox from "./object-box/structs";
import * as objectVec from "./object-vec/structs";
import * as quadraticVesting from "./quadratic-vesting/structs";
import * as typedId from "./typed-id/structs";
import {StructClassLoader} from "../_framework/loader";

export function registerClasses(loader: StructClassLoader) {
    loader.register(i128Type.I128);
    loader.register(i64Type.I64);
    loader.register(critBitU64.CB);
    loader.register(critBitU64.I);
    loader.register(critBitU64.O);
    loader.register(balances.Balances);
    loader.register(typedId.TypedID);
    loader.register(objectBox.ObjectBox);
    loader.register(bloomFilter.Filter);
    loader.register(box.Box);
    loader.register(critBit.CB);
    loader.register(critBit.I);
    loader.register(critBit.O);
    loader.register(escrow.Escrow);
    loader.register(escrowShared.Escrow);
    loader.register(linearVesting.ClawbackCapability);
    loader.register(linearVesting.Wallet);
    loader.register(objectVec.ObjectVec);
    loader.register(quadraticVesting.ClawbackCapability);
    loader.register(quadraticVesting.Wallet);
}
