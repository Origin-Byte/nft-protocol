import * as authlist from "./authlist/structs";
import * as frozenPub from "./frozen-pub/structs";
import * as obAuthlist from "./ob-authlist/structs";
import {StructClassLoader} from "../_framework/loader";

export function registerClasses(loader: StructClassLoader) {
    loader.register(authlist.AUTHLIST);
    loader.register(authlist.Authlist);
    loader.register(authlist.AuthlistOwnerCap);
    loader.register(authlist.CollectionKey);
    loader.register(frozenPub.FROZEN_PUB);
    loader.register(obAuthlist.OB_AUTHLIST);
}
