import { MedusaRequest } from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"

const DEFAULT_LIMIT = 20
const MAX_LIMIT = 100

export type ListParams = {
  limit: number
  offset: number
  /** Prêt à passer tel quel à `pagination.order` de query.graph. */
  order: Record<string, "ASC" | "DESC">
  /** Terme de recherche libre, déjà nettoyé. */
  q?: string
}

export type ParseOptions = {
  /** Champs sur lesquels le tri est autorisé. Tout le reste est refusé. */
  sortable: string[]
  /** Tri appliqué si le client n'en demande pas. Convention `-champ` = décroissant. */
  defaultOrder: string
}

/**
 * Lit `?limit`, `?offset`, `?order` et `?q` d'une liste vendeur.
 *
 * Convention de tri identique à celle de l'API admin Medusa : `?order=-created_at`
 * pour décroissant, `?order=title` pour croissant. Les champs triables sont
 * explicitement listés par la route — un `order` arbitraire finirait dans la
 * clause ORDER BY de l'ORM.
 */
export function parseListParams(req: MedusaRequest, opts: ParseOptions): ListParams {
  const { limit, offset, order, q } = req.query as Record<string, string | undefined>

  const parsedLimit = Number.parseInt(limit ?? "", 10)
  const parsedOffset = Number.parseInt(offset ?? "", 10)

  const raw = (order || opts.defaultOrder).trim()
  const direction: "ASC" | "DESC" = raw.startsWith("-") ? "DESC" : "ASC"
  const field = raw.replace(/^[-+]/, "")

  if (!opts.sortable.includes(field)) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      `Tri impossible sur '${field}'. Champs acceptés : ${opts.sortable.join(", ")}.`,
    )
  }

  const search = q?.trim()

  return {
    limit: Number.isFinite(parsedLimit)
      ? Math.min(Math.max(parsedLimit, 1), MAX_LIMIT)
      : DEFAULT_LIMIT,
    offset: Number.isFinite(parsedOffset) ? Math.max(parsedOffset, 0) : 0,
    order: { [field]: direction },
    q: search || undefined,
  }
}

/**
 * Construit un filtre de plage sur une date à partir de `?date_from` / `?date_to`,
 * ou `undefined` si aucune borne n'est fournie.
 */
export function parseDateRange(
  req: MedusaRequest,
): { $gte?: Date; $lte?: Date } | undefined {
  const { date_from, date_to } = req.query as Record<string, string | undefined>

  const range: { $gte?: Date; $lte?: Date } = {}
  if (date_from) {
    const d = new Date(date_from)
    if (!Number.isNaN(d.getTime())) range.$gte = d
  }
  if (date_to) {
    const d = new Date(date_to)
    if (!Number.isNaN(d.getTime())) range.$lte = d
  }

  return Object.keys(range).length ? range : undefined
}

/** Enveloppe de pagination commune à toutes les listes vendeur. */
export function paginationMeta(params: ListParams, count: number) {
  return {
    count,
    limit: params.limit,
    offset: params.offset,
    has_more: params.offset + params.limit < count,
  }
}
