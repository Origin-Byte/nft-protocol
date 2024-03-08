import * as frozenPub from "./frozen-pub/structs";
import * as kiosk from "./kiosk/structs";
import * as obKiosk from "./ob-kiosk/structs";
import {StructClassLoader} from "../_framework/loader";

export function registerClasses(loader: StructClassLoader) {
    loader.register(kiosk.KIOSK);
    loader.register(obKiosk.Witness);
    loader.register(obKiosk.AuthTransferRequestDfKey);
    loader.register(obKiosk.DepositSetting);
    loader.register(obKiosk.DepositSettingDfKey);
    loader.register(obKiosk.KioskOwnerCapDfKey);
    loader.register(obKiosk.NftRef);
    loader.register(obKiosk.NftRefsDfKey);
    loader.register(obKiosk.OB_KIOSK);
    loader.register(obKiosk.OwnerToken);
    loader.register(obKiosk.VersionDfKey);
    loader.register(frozenPub.FROZEN_PUB);
}
