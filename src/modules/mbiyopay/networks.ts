/**
 * Curated country/network/currency catalog for MBIYOPAY payin & payout.
 *
 * MBIYOPAY's Merchant API (the one this app integrates against — /payin,
 * /payout, /transactions/:id) does not expose a live "list supported
 * networks" endpoint; this table is sourced from their official Postman
 * collection (dashboard.mbiyo.africa/docs/postman). Keep it in sync by hand
 * if MBIYOPAY adds/removes country or network coverage.
 */
export interface MbiyoPayNetwork {
  id: string;
  label: string;
}

export interface MbiyoPayCountry {
  country_code: string;
  country_name: string;
  currency: string;
  networks: MbiyoPayNetwork[];
}

export const MBIYOPAY_COUNTRIES: MbiyoPayCountry[] = [
  {
    country_code: "CD",
    country_name: "République Démocratique du Congo",
    currency: "CDF",
    networks: [
      { id: "vodacom", label: "Vodacom M-Pesa" },
      { id: "airtel", label: "Airtel Money" },
      { id: "orange", label: "Orange Money" },
      { id: "africell", label: "Africell Money" },
    ],
  },
  {
    country_code: "CM",
    country_name: "Cameroun",
    currency: "XAF",
    networks: [
      { id: "mtn", label: "MTN Mobile Money" },
      { id: "orange", label: "Orange Money" },
    ],
  },
  {
    country_code: "BF",
    country_name: "Burkina Faso",
    currency: "XOF",
    networks: [
      { id: "orange", label: "Orange Money" },
      { id: "moov", label: "Moov Money" },
    ],
  },
  {
    country_code: "CI",
    country_name: "Côte d'Ivoire",
    currency: "XOF",
    networks: [
      { id: "orange", label: "Orange Money" },
      { id: "mtn", label: "MTN Mobile Money" },
      { id: "moov", label: "Moov Money" },
    ],
  },
  {
    country_code: "ML",
    country_name: "Mali",
    currency: "XOF",
    networks: [
      { id: "orange", label: "Orange Money" },
      { id: "moov", label: "Moov Money" },
    ],
  },
  {
    country_code: "BJ",
    country_name: "Bénin",
    currency: "XOF",
    networks: [
      { id: "mtn", label: "MTN Mobile Money" },
      { id: "moov", label: "Moov Money" },
      { id: "celtiis", label: "Celtiis Cash" },
    ],
  },
  {
    country_code: "CG",
    country_name: "Congo-Brazzaville",
    currency: "XAF",
    networks: [
      { id: "mtn", label: "MTN Mobile Money" },
    ],
  },
  {
    country_code: "SN",
    country_name: "Sénégal",
    currency: "XOF",
    networks: [
      { id: "orange", label: "Orange Money" },
      { id: "free", label: "Free Money" },
      { id: "wave", label: "Wave" },
    ],
  },
  {
    country_code: "TG",
    country_name: "Togo",
    currency: "XOF",
    networks: [
      { id: "moov", label: "Moov Money" },
      { id: "togocom", label: "Togocom Money (T-Money)" },
    ],
  },
  {
    country_code: "GM",
    country_name: "Gambie",
    currency: "GMD",
    networks: [
      { id: "qmoney", label: "QMoney" },
      { id: "afrimoney", label: "Afrimoney" },
      { id: "wave", label: "Wave" },
      { id: "aps", label: "APS" },
    ],
  },
  {
    country_code: "UG",
    country_name: "Ouganda",
    currency: "UGX",
    networks: [
      { id: "mtn", label: "MTN Mobile Money" },
    ],
  },
  {
    country_code: "TZ",
    country_name: "Tanzanie",
    currency: "TZS",
    networks: [
      { id: "vodacom", label: "Vodacom M-Pesa" },
      { id: "airtel", label: "Airtel Money" },
      { id: "tigo", label: "Tigo Pesa" },
      { id: "halotel", label: "Halotel Money" },
    ],
  },
  {
    country_code: "KE",
    country_name: "Kenya",
    currency: "KES",
    networks: [
      { id: "safaricom", label: "M-Pesa (Safaricom)" },
      { id: "airtel", label: "Airtel Money" },
    ],
  },
  {
    country_code: "RW",
    country_name: "Rwanda",
    currency: "RWF",
    networks: [
      { id: "mtn", label: "MTN Mobile Money" },
      { id: "airtel", label: "Airtel Money" },
    ],
  },
  {
    country_code: "EG",
    country_name: "Égypte",
    currency: "EGP",
    networks: [
      { id: "wallet", label: "Mobile Wallet" },
      { id: "cash", label: "Fawry Cash" },
    ],
  },
  {
    country_code: "ZA",
    country_name: "Afrique du Sud",
    currency: "ZAR",
    networks: [
      { id: "eft", label: "EFT" },
    ],
  },
  {
    country_code: "ZM",
    country_name: "Zambie",
    currency: "ZMW",
    networks: [
      { id: "mtn", label: "MTN Mobile Money" },
      { id: "airtel", label: "Airtel Money" },
      { id: "zamtel", label: "Zamtel Money" },
    ],
  },
  {
    country_code: "GH",
    country_name: "Ghana",
    currency: "GHS",
    networks: [
      { id: "mtn", label: "MTN Mobile Money" },
      { id: "airtel", label: "AirtelTigo Money" },
      { id: "vodafone", label: "Vodafone Cash" },
    ],
  },
  {
    country_code: "NG",
    country_name: "Nigéria",
    currency: "NGN",
    networks: [
      { id: "bank_transfer", label: "Virement bancaire" },
      { id: "opay", label: "OPay" },
      { id: "palmpay", label: "PalmPay" },
    ],
  },
]
