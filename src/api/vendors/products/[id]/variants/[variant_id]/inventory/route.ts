import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError, Modules } from "@medusajs/framework/utils"
import { z } from "@medusajs/framework/zod"

export const PostVendorInventorySchema = z.object({
  location_id: z.string(),
  adjustment: z.number().int(),
}).strict()

type PostBody = z.infer<typeof PostVendorInventorySchema>

async function assertProductOwnership(req: AuthenticatedMedusaRequest, productId: string): Promise<void> {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.products.id"],
    filters: { id: [req.auth_context.actor_id] }
  })
  const productIds = (vendorAdmin.vendor.products || []).map((p: { id: string }) => p.id)
  if (!productIds.includes(productId)) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Product not found")
  }
}

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const { id, variant_id } = req.params
  await assertProductOwnership(req, id)

  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  
  const { data: [variant] } = await query.graph({
    entity: "variant",
    fields: [
      "id", 
      "title", 
      "sku", 
      "inventory.id",
      "inventory.location_levels.location_id",
      "inventory.location_levels.stocked_quantity",
      "inventory.location_levels.reserved_quantity",
      "inventory.location_levels.available_quantity",
    ],
    filters: { id: variant_id }
  })

  if (!variant) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Variant not found")
  }

  res.json({ inventory: variant.inventory })
}

export const POST = async (req: AuthenticatedMedusaRequest<PostBody>, res: MedusaResponse) => {
  const { id, variant_id } = req.params
  const { location_id, adjustment } = req.validatedBody
  
  await assertProductOwnership(req, id)

  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const inventoryModule = req.scope.resolve(Modules.INVENTORY)

  // 1. Find inventory item for variant
  const { data: [variant] } = await query.graph({
    entity: "variant",
    fields: ["id", "inventory.id"],
    filters: { id: variant_id }
  })

  if (!variant || !variant.inventory?.[0]?.id) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Inventory item not found for this variant")
  }

  const inventoryItemId = variant.inventory[0].id

  // 2. Check if inventory level exists for this location
  const inventoryLevels = await inventoryModule.listInventoryLevels({
    inventory_item_id: [inventoryItemId],
    location_id: [location_id],
  })

  if (inventoryLevels.length === 0) {
    // 3. Create inventory level if it doesn't exist
    await inventoryModule.createInventoryLevels([
      {
        inventory_item_id: inventoryItemId,
        location_id: location_id,
        stocked_quantity: adjustment,
      },
    ])
  } else {
    // 4. Adjust inventory if it already exists
    await inventoryModule.adjustInventory(inventoryItemId, location_id, adjustment)
  }

  // 5. Return updated inventory
  const { data: [updatedVariant] } = await query.graph({
    entity: "variant",
    fields: [
      "inventory.location_levels.location_id",
      "inventory.location_levels.stocked_quantity",
      "inventory.location_levels.available_quantity",
    ],
    filters: { id: variant_id }
  })

  res.json({ inventory: updatedVariant.inventory })
}
