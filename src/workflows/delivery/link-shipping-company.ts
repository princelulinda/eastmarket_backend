import { createWorkflow, WorkflowResponse, createStep, StepResponse } from "@medusajs/framework/workflows-sdk"
import { ContainerRegistrationKeys, Modules } from "@medusajs/framework/utils"

export const linkShippingCompanyStep = createStep(
  "link-shipping-company-step",
  async (data: { shipping_option_id: string; delivery_company_id: string }, { container }) => {
    const link = container.resolve(ContainerRegistrationKeys.LINK);
    
    // Dismiss the exact link if it already exists to avoid duplication errors
    await link.dismiss({
      "delivery": {
        delivery_company_id: data.delivery_company_id,
      },
      [Modules.FULFILLMENT]: {
        shipping_option_id: data.shipping_option_id,
      }
    });

    await link.create({
      "delivery": {
        delivery_company_id: data.delivery_company_id,
      },
      [Modules.FULFILLMENT]: {
        shipping_option_id: data.shipping_option_id,
      }
    });
    
    return new StepResponse(true, { shipping_option_id: data.shipping_option_id, delivery_company_id: data.delivery_company_id });
  },
  async (data, { container }) => {
    const link = container.resolve(ContainerRegistrationKeys.LINK);
    await link.dismiss({
      "delivery": {
        delivery_company_id: data.delivery_company_id,
      },
      [Modules.FULFILLMENT]: {
        shipping_option_id: data.shipping_option_id,
      }
    });
  }
)

const linkShippingCompanyWorkflow = createWorkflow(
  "link-shipping-company",
  function (input: { shipping_option_id: string; delivery_company_id: string }) {
    linkShippingCompanyStep(input)
    return new WorkflowResponse({})
  }
)

export default linkShippingCompanyWorkflow
