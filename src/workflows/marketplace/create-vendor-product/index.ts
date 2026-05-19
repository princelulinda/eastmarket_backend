import { CreateProductWorkflowInputDTO } from "@medusajs/framework/types"
import { 
  createWorkflow, 
  transform, 
  WorkflowResponse
} from "@medusajs/framework/workflows-sdk"
import { 
  createProductsWorkflow, 
  CreateProductsWorkflowInput, 
  createRemoteLinkStep, 
  useQueryGraphStep
} from "@medusajs/medusa/core-flows"
import { MARKETPLACE_MODULE } from "../../../modules/marketplace"
import { Modules } from "@medusajs/framework/utils"

type WorkflowInput = {
  vendor_admin_id: string
  product: CreateProductWorkflowInputDTO
}

const createVendorProductWorkflow = createWorkflow(
  "create-vendor-product",
  (input: WorkflowInput) => {
    const { data: stores } = useQueryGraphStep({
      entity: "store",
      fields: ["default_sales_channel_id"],
    })

    // Retrieve the default shipping profile so vendor products get calculated_price
    const { data: shippingProfiles } = useQueryGraphStep({
      entity: "shipping_profile",
      fields: ["id", "type"],
      filters: { type: "default" },
    }).config({ name: "retrieve-default-shipping-profile" })

    const productData = transform({
      input,
      stores,
      shippingProfiles,
    }, (data) => {
      const defaultShippingProfileId = data.shippingProfiles?.[0]?.id
      console.log("[create-vendor-product] shipping_profile_id:", defaultShippingProfileId)
      console.log("[create-vendor-product] variants prices:", JSON.stringify(
        data.input.product.variants?.map((v: any) => ({ title: v.title, prices: v.prices })),
        null, 2
      ))
      return {
        products: [{
          ...data.input.product,
          ...(defaultShippingProfileId && !data.input.product.shipping_profile_id
            ? { shipping_profile_id: defaultShippingProfileId }
            : {}),
          sales_channels: [
            {
              id: data.stores[0].default_sales_channel_id
            }
          ]
        }]
      }
    })

    const createdProducts = createProductsWorkflow.runAsStep({
      input: productData as CreateProductsWorkflowInput
    })
    
    const { data: vendorAdmins } = useQueryGraphStep({
      entity: "vendor_admin",
      fields: ["vendor.id"],
      filters: {
        id: input.vendor_admin_id
      }
    }).config({ name: "retrieve-vendor-admins" })

    const linksToCreate = transform({
      input,
      createdProducts,
      vendorAdmins
    }, (data) => {
      return data.createdProducts.map((product) => {
        return {
          [MARKETPLACE_MODULE]: {
            vendor_id: data.vendorAdmins[0].vendor.id
          },
          [Modules.PRODUCT]: {
            product_id: product.id
          }
        }
      })
    })

    createRemoteLinkStep(linksToCreate)
    
    const { data: products } = useQueryGraphStep({
      entity: "product",
      fields: ["*", "variants.*"],
      filters: {
        id: createdProducts[0].id
      }
    }).config({ name: "retrieve-products" })

    return new WorkflowResponse({
      product: products[0]
    })
  }
)

export default createVendorProductWorkflow