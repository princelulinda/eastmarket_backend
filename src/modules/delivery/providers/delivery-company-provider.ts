import { 
  AbstractFulfillmentProviderService,
  ModuleProvider,
  Modules
} from "@medusajs/framework/utils"

export class DeliveryCompanyProvider extends AbstractFulfillmentProviderService {
  static identifier = "delivery-company-provider"

  constructor(protected container: any, protected options: any) {
    super()
  }

  async createFulfillment(data: any): Promise<any> {
    return {
      id: "ful_" + Math.random().toString(36).substr(2, 9),
      provider_id: DeliveryCompanyProvider.identifier,
      data: { ...data },
      metadata: {},
    }
  }

  async cancelFulfillment(fulfillment: any): Promise<any> {
    return fulfillment
  }

  async createReturnFulfillment(data: any): Promise<any> {
    throw new Error("Method not implemented.")
  }

  async getFulfillmentOptions(): Promise<any[]> {
    return [
      {
        id: "standard-delivery",
        is_active: true,
      },
    ]
  }

  async validateFulfillmentData(optionData: any, data: any, context: any): Promise<any> {
    return data
  }

  async validateOption(data: any): Promise<boolean> {
    return true
  }
}

export default ModuleProvider(Modules.FULFILLMENT, {
  services: [DeliveryCompanyProvider],
})

