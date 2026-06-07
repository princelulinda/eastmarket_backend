import DeliveryCompany from "./src/modules/delivery/models/delivery-company";
console.log("Raw model toJSON:", DeliveryCompany.toJSON());
import { linkable } from "./src/modules/delivery/index";
console.log("Manually exported linkable:", linkable.deliveryCompany.linkable.toJSON());
