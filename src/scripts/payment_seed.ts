import { ExecArgs } from "@medusajs/framework/types"
import { ContainerRegistrationKeys, Modules } from "@medusajs/framework/utils"

export default async function seed({ container }: ExecArgs) {
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER)
  const link = container.resolve(ContainerRegistrationKeys.LINK)

  const regionId = "reg_01KSR0QAP4C6SG0JX6SG5ZK6BP"

  // Provider IDs follow the format: pp_{identifier}_{config_id}
  // KashFlow: identifier="kashflow", config id="kashflow" → pp_kashflow_kashflow
  const providers = [
    "pp_system_default",
    "pp_stripe_stripe",
    "pp_kashflow_kashflow",
  ]

  logger.info("Linking payment providers to East region...")

  for (const providerId of providers) {
    try {
      await link.create({
        [Modules.REGION]: {
          region_id: regionId,
        },
        [Modules.PAYMENT]: {
          payment_provider_id: providerId,
        },
      })
      logger.info(`Linked: ${providerId}`)
    } catch (e: any) {
      if (e?.message?.includes("duplicate") || e?.message?.includes("already exists") || e?.code === "23505") {
        logger.warn(`Provider ${providerId} already linked, skipping.`)
      } else {
        logger.error(`Failed to link ${providerId}: ${e.message}`)
      }
    }
  }

  logger.info("Payment seed completed 🚀")
}