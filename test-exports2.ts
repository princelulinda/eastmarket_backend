import DeliveryCompany from "./src/modules/delivery/models/delivery-company";
console.log("Raw model toJSON:", (DeliveryCompany as any).toJSON());
import { linkable } from "./src/modules/delivery/index";
console.log("Manually exported linkable:", (linkable as any).deliveryCompany?.linkable?.toJSON?.());
