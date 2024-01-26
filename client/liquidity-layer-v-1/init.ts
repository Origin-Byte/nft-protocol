import * as bidding from "./bidding/structs";
import * as frozenPub from "./frozen-pub/structs";
import * as liquidityLayer from "./liquidity-layer/structs";
import * as orderbook from "./orderbook/structs";
import * as trading from "./trading/structs";
import {StructClassLoader} from "../_framework/loader";

export function registerClasses(loader: StructClassLoader) {
    loader.register(trading.AskCommission);
    loader.register(trading.BidCommission);
    loader.register(bidding.Witness);
    loader.register(bidding.Bid);
    loader.register(bidding.BidClosedEvent);
    loader.register(bidding.BidCreatedEvent);
    loader.register(bidding.BidMatchedEvent);
    loader.register(frozenPub.FROZEN_PUB);
    loader.register(liquidityLayer.LIQUIDITY_LAYER);
    loader.register(orderbook.Witness);
    loader.register(orderbook.Bid);
    loader.register(orderbook.BidClosedEvent);
    loader.register(orderbook.BidCreatedEvent);
    loader.register(orderbook.AdministratorsDfKey);
    loader.register(orderbook.Ask);
    loader.register(orderbook.AskClosedEvent);
    loader.register(orderbook.AskCreatedEvent);
    loader.register(orderbook.IsDeprecatedDfKey);
    loader.register(orderbook.Orderbook);
    loader.register(orderbook.OrderbookCreatedEvent);
    loader.register(orderbook.TimeLockDfKey);
    loader.register(orderbook.TradeFilledEvent);
    loader.register(orderbook.TradeInfo);
    loader.register(orderbook.TradeIntermediate);
    loader.register(orderbook.TradeIntermediateDfKey);
    loader.register(orderbook.UnderMigrationToDfKey);
    loader.register(orderbook.WitnessProtectedActions);
}
