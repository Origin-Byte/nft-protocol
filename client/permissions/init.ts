import * as frozenPub from "./frozen-pub/structs";
import * as frozenPublisher from "./frozen-publisher/structs";
import * as permissions from "./permissions/structs";
import * as quorum from "./quorum/structs";
import * as witness from "./witness/structs";
import {StructClassLoader} from "../_framework/loader";

export function registerClasses(loader: StructClassLoader) {
    loader.register(witness.Witness);
    loader.register(witness.WitnessGenerator);
    loader.register(frozenPublisher.FROZEN_PUBLISHER);
    loader.register(frozenPublisher.FrozenPublisher);
    loader.register(frozenPub.FROZEN_PUB);
    loader.register(permissions.PERMISSIONS);
    loader.register(quorum.AddAdmin);
    loader.register(quorum.AddDelegate);
    loader.register(quorum.AdminField);
    loader.register(quorum.CreateQuorumEvent);
    loader.register(quorum.ExtensionToken);
    loader.register(quorum.Foo);
    loader.register(quorum.MemberField);
    loader.register(quorum.Quorum);
    loader.register(quorum.RemoveAdmin);
    loader.register(quorum.RemoveDelegate);
    loader.register(quorum.ReturnReceipt);
    loader.register(quorum.Signatures);
}
