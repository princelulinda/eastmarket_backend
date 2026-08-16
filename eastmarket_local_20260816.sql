--
-- PostgreSQL database dump
--

\restrict 8BhKdivFFnKdFB6MX3QTYs9A1zUVeopx4c8fSWV73rVTBsuScwHTdceNWV8U1pm

-- Dumped from database version 18.4 (Ubuntu 18.4-0ubuntu0.26.04.1)
-- Dumped by pg_dump version 18.4 (Ubuntu 18.4-0ubuntu0.26.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: claim_reason_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.claim_reason_enum AS ENUM (
    'missing_item',
    'wrong_item',
    'production_failure',
    'other'
);


--
-- Name: order_claim_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.order_claim_type_enum AS ENUM (
    'refund',
    'replace'
);


--
-- Name: order_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.order_status_enum AS ENUM (
    'pending',
    'completed',
    'draft',
    'archived',
    'canceled',
    'requires_action'
);


--
-- Name: return_status_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.return_status_enum AS ENUM (
    'open',
    'requested',
    'received',
    'partially_received',
    'canceled'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account_holder; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_holder (
    id text NOT NULL,
    provider_id text NOT NULL,
    external_id text NOT NULL,
    email text,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: analytics_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.analytics_event (
    id text NOT NULL,
    product_id text NOT NULL,
    vendor_id text NOT NULL,
    source text NOT NULL,
    campaign text,
    event_type text NOT NULL,
    order_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT analytics_event_event_type_check CHECK ((event_type = ANY (ARRAY['click'::text, 'conversion'::text])))
);


--
-- Name: api_key; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_key (
    id text NOT NULL,
    token text NOT NULL,
    salt text NOT NULL,
    redacted text NOT NULL,
    title text NOT NULL,
    type text NOT NULL,
    last_used_at timestamp with time zone,
    created_by text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_by text,
    revoked_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT api_key_type_check CHECK ((type = ANY (ARRAY['publishable'::text, 'secret'::text])))
);


--
-- Name: app_notification; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_notification (
    id text NOT NULL,
    recipient_id text NOT NULL,
    recipient_type text NOT NULL,
    type text NOT NULL,
    title text NOT NULL,
    body text NOT NULL,
    data jsonb,
    is_read boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT app_notification_recipient_type_check CHECK ((recipient_type = ANY (ARRAY['customer'::text, 'vendor'::text]))),
    CONSTRAINT app_notification_type_check CHECK ((type = ANY (ARRAY['new_message'::text, 'new_order'::text, 'order_status'::text, 'order_shipped'::text, 'order_delivered'::text, 'order_cancelled'::text, 'new_review'::text, 'reward_won'::text, 'streak_milestone'::text, 'new_video'::text, 'referral_reward'::text, 'offer_response'::text, 'chat_reminder'::text, 'cart_reminder'::text, 'system'::text])))
);


--
-- Name: application_method_buy_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_method_buy_rules (
    application_method_id text NOT NULL,
    promotion_rule_id text NOT NULL
);


--
-- Name: application_method_target_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_method_target_rules (
    application_method_id text NOT NULL,
    promotion_rule_id text NOT NULL
);


--
-- Name: auth_identity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_identity (
    id text NOT NULL,
    app_metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: capture; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.capture (
    id text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    payment_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by text,
    metadata jsonb
);


--
-- Name: cart; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart (
    id text NOT NULL,
    region_id text,
    customer_id text,
    sales_channel_id text,
    email text,
    currency_code text NOT NULL,
    shipping_address_id text,
    billing_address_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    completed_at timestamp with time zone,
    locale text
);


--
-- Name: cart_address; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_address (
    id text NOT NULL,
    customer_id text,
    company text,
    first_name text,
    last_name text,
    address_1 text,
    address_2 text,
    city text,
    country_code text,
    province text,
    postal_code text,
    phone text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: cart_line_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_line_item (
    id text NOT NULL,
    cart_id text NOT NULL,
    title text NOT NULL,
    subtitle text,
    thumbnail text,
    quantity integer NOT NULL,
    variant_id text,
    product_id text,
    product_title text,
    product_description text,
    product_subtitle text,
    product_type text,
    product_collection text,
    product_handle text,
    variant_sku text,
    variant_barcode text,
    variant_title text,
    variant_option_values jsonb,
    requires_shipping boolean DEFAULT true NOT NULL,
    is_discountable boolean DEFAULT true NOT NULL,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    compare_at_unit_price numeric,
    raw_compare_at_unit_price jsonb,
    unit_price numeric NOT NULL,
    raw_unit_price jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    product_type_id text,
    is_custom_price boolean DEFAULT false NOT NULL,
    is_giftcard boolean DEFAULT false NOT NULL,
    CONSTRAINT cart_line_item_unit_price_check CHECK ((unit_price >= (0)::numeric))
);


--
-- Name: cart_line_item_adjustment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_line_item_adjustment (
    id text NOT NULL,
    description text,
    promotion_id text,
    code text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    item_id text,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    CONSTRAINT cart_line_item_adjustment_check CHECK ((amount >= (0)::numeric))
);


--
-- Name: cart_line_item_tax_line; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_line_item_tax_line (
    id text NOT NULL,
    description text,
    tax_rate_id text,
    code text NOT NULL,
    rate real NOT NULL,
    provider_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    item_id text
);


--
-- Name: cart_payment_collection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_payment_collection (
    cart_id character varying(255) NOT NULL,
    payment_collection_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: cart_promotion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_promotion (
    cart_id character varying(255) NOT NULL,
    promotion_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: cart_shipping_method; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_shipping_method (
    id text NOT NULL,
    cart_id text NOT NULL,
    name text NOT NULL,
    description jsonb,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    shipping_option_id text,
    data jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT cart_shipping_method_check CHECK ((amount >= (0)::numeric))
);


--
-- Name: cart_shipping_method_adjustment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_shipping_method_adjustment (
    id text NOT NULL,
    description text,
    promotion_id text,
    code text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    shipping_method_id text
);


--
-- Name: cart_shipping_method_tax_line; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_shipping_method_tax_line (
    id text NOT NULL,
    description text,
    tax_rate_id text,
    code text NOT NULL,
    rate real NOT NULL,
    provider_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    shipping_method_id text
);


--
-- Name: conversation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conversation (
    id text NOT NULL,
    customer_id text,
    vendor_id text,
    last_message_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    type text DEFAULT 'direct'::text NOT NULL,
    CONSTRAINT conversation_type_check CHECK ((type = ANY (ARRAY['direct'::text, 'broadcast'::text])))
);


--
-- Name: credit_line; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.credit_line (
    id text NOT NULL,
    cart_id text NOT NULL,
    reference text,
    reference_id text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: currency; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.currency (
    code text NOT NULL,
    symbol text NOT NULL,
    symbol_native text NOT NULL,
    decimal_digits integer DEFAULT 0 NOT NULL,
    rounding numeric DEFAULT 0 NOT NULL,
    raw_rounding jsonb NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: customer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer (
    id text NOT NULL,
    company_name text,
    first_name text,
    last_name text,
    email text,
    phone text,
    has_account boolean DEFAULT false NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by text
);


--
-- Name: customer_account_holder; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_account_holder (
    customer_id character varying(255) NOT NULL,
    account_holder_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: customer_address; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_address (
    id text NOT NULL,
    customer_id text NOT NULL,
    address_name text,
    is_default_shipping boolean DEFAULT false NOT NULL,
    is_default_billing boolean DEFAULT false NOT NULL,
    company text,
    first_name text,
    last_name text,
    address_1 text,
    address_2 text,
    city text,
    country_code text,
    province text,
    postal_code text,
    phone text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: customer_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_group (
    id text NOT NULL,
    name text NOT NULL,
    metadata jsonb,
    created_by text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: customer_group_customer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_group_customer (
    id text NOT NULL,
    customer_id text NOT NULL,
    customer_group_id text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text,
    deleted_at timestamp with time zone
);


--
-- Name: customer_loyalty; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_loyalty (
    id text NOT NULL,
    customer_id text NOT NULL,
    points_balance integer DEFAULT 0 NOT NULL,
    lifetime_points integer DEFAULT 0 NOT NULL,
    tier text DEFAULT 'bronze'::text NOT NULL,
    current_streak integer DEFAULT 0 NOT NULL,
    longest_streak integer DEFAULT 0 NOT NULL,
    last_checkin_date text,
    last_wheel_spin_date text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    referral_code text,
    CONSTRAINT customer_loyalty_tier_check CHECK ((tier = ANY (ARRAY['bronze'::text, 'silver'::text, 'gold'::text, 'platinum'::text])))
);


--
-- Name: customer_payment_method; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_payment_method (
    id text NOT NULL,
    customer_id text NOT NULL,
    provider_id text NOT NULL,
    data jsonb,
    is_default boolean DEFAULT false NOT NULL,
    label text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: daily_check_in; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.daily_check_in (
    id text NOT NULL,
    checkin_date text NOT NULL,
    streak_count_at_checkin integer NOT NULL,
    points_earned integer NOT NULL,
    loyalty_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: delivery_company; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivery_company (
    id text NOT NULL,
    name text NOT NULL,
    logo text,
    phone text,
    email text NOT NULL,
    website text,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: delivery_delivery_company_fulfillment_shipping_option; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivery_delivery_company_fulfillment_shipping_option (
    delivery_company_id character varying(255) CONSTRAINT delivery_delivery_company_fulfillm_delivery_company_id_not_null NOT NULL,
    shipping_option_id character varying(255) CONSTRAINT delivery_delivery_company_fulfillme_shipping_option_id_not_null NOT NULL,
    id character varying(255) CONSTRAINT delivery_delivery_company_fulfillment_shipping_opti_id_not_null NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP CONSTRAINT delivery_delivery_company_fulfillment_shipp_created_at_not_null NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP CONSTRAINT delivery_delivery_company_fulfillment_shipp_updated_at_not_null NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: delivery_driver; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivery_driver (
    id text NOT NULL,
    name text NOT NULL,
    phone text NOT NULL,
    vehicle_details text,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb,
    delivery_company_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: flash_sale; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flash_sale (
    id text NOT NULL,
    vendor_id text,
    title text NOT NULL,
    banner_color text,
    product_ids jsonb,
    promotion_id text NOT NULL,
    campaign_id text NOT NULL,
    discount_type text NOT NULL,
    discount_value integer NOT NULL,
    starts_at timestamp with time zone NOT NULL,
    ends_at timestamp with time zone NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT flash_sale_discount_type_check CHECK ((discount_type = ANY (ARRAY['percentage'::text, 'fixed'::text])))
);


--
-- Name: fulfillment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fulfillment (
    id text NOT NULL,
    location_id text NOT NULL,
    packed_at timestamp with time zone,
    shipped_at timestamp with time zone,
    delivered_at timestamp with time zone,
    canceled_at timestamp with time zone,
    data jsonb,
    provider_id text,
    shipping_option_id text,
    metadata jsonb,
    delivery_address_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    marked_shipped_by text,
    created_by text,
    requires_shipping boolean DEFAULT true NOT NULL
);


--
-- Name: fulfillment_address; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fulfillment_address (
    id text NOT NULL,
    company text,
    first_name text,
    last_name text,
    address_1 text,
    address_2 text,
    city text,
    country_code text,
    province text,
    postal_code text,
    phone text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: fulfillment_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fulfillment_item (
    id text NOT NULL,
    title text NOT NULL,
    sku text NOT NULL,
    barcode text NOT NULL,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    line_item_id text,
    inventory_item_id text,
    fulfillment_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: fulfillment_label; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fulfillment_label (
    id text NOT NULL,
    tracking_number text NOT NULL,
    tracking_url text NOT NULL,
    label_url text NOT NULL,
    fulfillment_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: fulfillment_provider; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fulfillment_provider (
    id text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: fulfillment_set; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fulfillment_set (
    id text NOT NULL,
    name text NOT NULL,
    type text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: geo_zone; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.geo_zone (
    id text NOT NULL,
    type text DEFAULT 'country'::text NOT NULL,
    country_code text NOT NULL,
    province_code text,
    city text,
    service_zone_id text NOT NULL,
    postal_expression jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT geo_zone_type_check CHECK ((type = ANY (ARRAY['country'::text, 'province'::text, 'city'::text, 'zip'::text])))
);


--
-- Name: image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.image (
    id text NOT NULL,
    url text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    rank integer DEFAULT 0 NOT NULL,
    product_id text NOT NULL
);


--
-- Name: inventory_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory_item (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    sku text,
    origin_country text,
    hs_code text,
    mid_code text,
    material text,
    weight integer,
    length integer,
    height integer,
    width integer,
    requires_shipping boolean DEFAULT true NOT NULL,
    description text,
    title text,
    thumbnail text,
    metadata jsonb
);


--
-- Name: inventory_level; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory_level (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    inventory_item_id text NOT NULL,
    location_id text NOT NULL,
    stocked_quantity numeric DEFAULT 0 NOT NULL,
    reserved_quantity numeric DEFAULT 0 NOT NULL,
    incoming_quantity numeric DEFAULT 0 NOT NULL,
    metadata jsonb,
    raw_stocked_quantity jsonb,
    raw_reserved_quantity jsonb,
    raw_incoming_quantity jsonb
);


--
-- Name: invite; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invite (
    id text NOT NULL,
    email text NOT NULL,
    accepted boolean DEFAULT false NOT NULL,
    token text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: link_module_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.link_module_migrations (
    id integer NOT NULL,
    table_name character varying(255) NOT NULL,
    link_descriptor jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: link_module_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.link_module_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: link_module_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.link_module_migrations_id_seq OWNED BY public.link_module_migrations.id;


--
-- Name: locale; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locale (
    id text NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: location_fulfillment_provider; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.location_fulfillment_provider (
    stock_location_id character varying(255) NOT NULL,
    fulfillment_provider_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: location_fulfillment_set; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.location_fulfillment_set (
    stock_location_id character varying(255) NOT NULL,
    fulfillment_set_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: loyalty_coupon; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.loyalty_coupon (
    id text NOT NULL,
    customer_id text NOT NULL,
    promotion_id text NOT NULL,
    code text NOT NULL,
    source text NOT NULL,
    discount_type text NOT NULL,
    discount_value integer,
    status text DEFAULT 'issued'::text NOT NULL,
    expires_at timestamp with time zone,
    redeemed_at timestamp with time zone,
    redeemed_order_id text,
    source_ref_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT loyalty_coupon_discount_type_check CHECK ((discount_type = ANY (ARRAY['percentage'::text, 'fixed'::text, 'free_shipping'::text]))),
    CONSTRAINT loyalty_coupon_source_check CHECK ((source = ANY (ARRAY['wheel'::text, 'checkin_milestone'::text, 'referral'::text, 'manual'::text]))),
    CONSTRAINT loyalty_coupon_status_check CHECK ((status = ANY (ARRAY['issued'::text, 'redeemed'::text, 'expired'::text])))
);


--
-- Name: loyalty_transaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.loyalty_transaction (
    id text NOT NULL,
    customer_id text NOT NULL,
    type text NOT NULL,
    points_delta integer NOT NULL,
    balance_after integer NOT NULL,
    description text,
    ref_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT loyalty_transaction_type_check CHECK ((type = ANY (ARRAY['checkin'::text, 'wheel_spin'::text, 'redeem_adjustment'::text, 'admin_adjust'::text, 'chat_engagement'::text])))
);


--
-- Name: marketplace_vendor_order_order; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.marketplace_vendor_order_order (
    vendor_id character varying(255) NOT NULL,
    order_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: marketplace_vendor_product_product; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.marketplace_vendor_product_product (
    vendor_id character varying(255) NOT NULL,
    product_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: marketplace_vendor_promotion_promotion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.marketplace_vendor_promotion_promotion (
    vendor_id character varying(255) NOT NULL,
    promotion_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: marketplace_vendor_stock_location_stock_location; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.marketplace_vendor_stock_location_stock_location (
    vendor_id character varying(255) CONSTRAINT marketplace_vendor_stock_location_stock_loca_vendor_id_not_null NOT NULL,
    stock_location_id character varying(255) CONSTRAINT marketplace_vendor_stock_location_st_stock_location_id_not_null NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP CONSTRAINT marketplace_vendor_stock_location_stock_loc_created_at_not_null NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP CONSTRAINT marketplace_vendor_stock_location_stock_loc_updated_at_not_null NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: message; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.message (
    id text NOT NULL,
    conversation_id text NOT NULL,
    sender_type text NOT NULL,
    sender_id text NOT NULL,
    content text NOT NULL,
    type text DEFAULT 'text'::text NOT NULL,
    file_url text,
    is_read boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    reactions jsonb,
    delivered_at timestamp with time zone,
    reply_to_id text,
    metadata jsonb,
    CONSTRAINT message_sender_type_check CHECK ((sender_type = ANY (ARRAY['customer'::text, 'vendor'::text]))),
    CONSTRAINT message_type_check CHECK ((type = ANY (ARRAY['text'::text, 'image'::text, 'file'::text, 'audio'::text, 'product'::text, 'offer'::text, 'coupon'::text, 'order_update'::text, 'flash_sale'::text, 'video'::text, 'system'::text])))
);


--
-- Name: mikro_orm_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mikro_orm_migrations (
    id integer NOT NULL,
    name character varying(255),
    executed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: mikro_orm_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mikro_orm_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mikro_orm_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mikro_orm_migrations_id_seq OWNED BY public.mikro_orm_migrations.id;


--
-- Name: notification; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification (
    id text NOT NULL,
    "to" text NOT NULL,
    channel text NOT NULL,
    template text,
    data jsonb,
    trigger_type text,
    resource_id text,
    resource_type text,
    receiver_id text,
    original_notification_id text,
    idempotency_key text,
    external_id text,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    status text DEFAULT 'pending'::text NOT NULL,
    "from" text,
    provider_data jsonb,
    CONSTRAINT notification_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'success'::text, 'failure'::text])))
);


--
-- Name: notification_preference; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification_preference (
    id text NOT NULL,
    recipient_id text NOT NULL,
    recipient_type text NOT NULL,
    prefs jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT notification_preference_recipient_type_check CHECK ((recipient_type = ANY (ARRAY['customer'::text, 'vendor'::text])))
);


--
-- Name: notification_provider; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification_provider (
    id text NOT NULL,
    handle text NOT NULL,
    name text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    channels text[] DEFAULT '{}'::text[] NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."order" (
    id text NOT NULL,
    region_id text,
    display_id integer,
    customer_id text,
    version integer DEFAULT 1 NOT NULL,
    sales_channel_id text,
    status public.order_status_enum DEFAULT 'pending'::public.order_status_enum NOT NULL,
    is_draft_order boolean DEFAULT false NOT NULL,
    email text,
    currency_code text NOT NULL,
    shipping_address_id text,
    billing_address_id text,
    no_notification boolean,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    canceled_at timestamp with time zone,
    custom_display_id text,
    locale text
);


--
-- Name: order_address; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_address (
    id text NOT NULL,
    customer_id text,
    company text,
    first_name text,
    last_name text,
    address_1 text,
    address_2 text,
    city text,
    country_code text,
    province text,
    postal_code text,
    phone text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order_cart; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_cart (
    order_id character varying(255) NOT NULL,
    cart_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order_change; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_change (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer NOT NULL,
    description text,
    status text DEFAULT 'pending'::text NOT NULL,
    internal_note text,
    created_by text,
    requested_by text,
    requested_at timestamp with time zone,
    confirmed_by text,
    confirmed_at timestamp with time zone,
    declined_by text,
    declined_reason text,
    metadata jsonb,
    declined_at timestamp with time zone,
    canceled_by text,
    canceled_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    change_type text,
    deleted_at timestamp with time zone,
    return_id text,
    claim_id text,
    exchange_id text,
    carry_over_promotions boolean,
    CONSTRAINT order_change_status_check CHECK ((status = ANY (ARRAY['confirmed'::text, 'declined'::text, 'requested'::text, 'pending'::text, 'canceled'::text])))
);


--
-- Name: order_change_action; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_change_action (
    id text NOT NULL,
    order_id text,
    version integer,
    ordering bigint NOT NULL,
    order_change_id text,
    reference text,
    reference_id text,
    action text NOT NULL,
    details jsonb,
    amount numeric,
    raw_amount jsonb,
    internal_note text,
    applied boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    return_id text,
    claim_id text,
    exchange_id text
);


--
-- Name: order_change_action_ordering_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_change_action_ordering_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_change_action_ordering_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_change_action_ordering_seq OWNED BY public.order_change_action.ordering;


--
-- Name: order_claim; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_claim (
    id text NOT NULL,
    order_id text NOT NULL,
    return_id text,
    order_version integer NOT NULL,
    display_id integer NOT NULL,
    type public.order_claim_type_enum NOT NULL,
    no_notification boolean,
    refund_amount numeric,
    raw_refund_amount jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    canceled_at timestamp with time zone,
    created_by text
);


--
-- Name: order_claim_display_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_claim_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_claim_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_claim_display_id_seq OWNED BY public.order_claim.display_id;


--
-- Name: order_claim_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_claim_item (
    id text NOT NULL,
    claim_id text NOT NULL,
    item_id text NOT NULL,
    is_additional_item boolean DEFAULT false NOT NULL,
    reason public.claim_reason_enum,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    note text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order_claim_item_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_claim_item_image (
    id text NOT NULL,
    claim_item_id text NOT NULL,
    url text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order_credit_line; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_credit_line (
    id text NOT NULL,
    order_id text NOT NULL,
    reference text,
    reference_id text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    version integer DEFAULT 1 NOT NULL
);


--
-- Name: order_display_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_display_id_seq OWNED BY public."order".display_id;


--
-- Name: order_exchange; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_exchange (
    id text NOT NULL,
    order_id text NOT NULL,
    return_id text,
    order_version integer NOT NULL,
    display_id integer NOT NULL,
    no_notification boolean,
    allow_backorder boolean DEFAULT false NOT NULL,
    difference_due numeric,
    raw_difference_due jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    canceled_at timestamp with time zone,
    created_by text
);


--
-- Name: order_exchange_display_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_exchange_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_exchange_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_exchange_display_id_seq OWNED BY public.order_exchange.display_id;


--
-- Name: order_exchange_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_exchange_item (
    id text NOT NULL,
    exchange_id text NOT NULL,
    item_id text NOT NULL,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    note text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order_fulfillment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_fulfillment (
    order_id character varying(255) NOT NULL,
    fulfillment_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_item (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer NOT NULL,
    item_id text NOT NULL,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    fulfilled_quantity numeric NOT NULL,
    raw_fulfilled_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL,
    shipped_quantity numeric NOT NULL,
    raw_shipped_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL,
    return_requested_quantity numeric NOT NULL,
    raw_return_requested_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL,
    return_received_quantity numeric NOT NULL,
    raw_return_received_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL,
    return_dismissed_quantity numeric NOT NULL,
    raw_return_dismissed_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL,
    written_off_quantity numeric NOT NULL,
    raw_written_off_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    delivered_quantity numeric DEFAULT 0 NOT NULL,
    raw_delivered_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL,
    unit_price numeric,
    raw_unit_price jsonb,
    compare_at_unit_price numeric,
    raw_compare_at_unit_price jsonb
);


--
-- Name: order_line_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_line_item (
    id text NOT NULL,
    totals_id text,
    title text NOT NULL,
    subtitle text,
    thumbnail text,
    variant_id text,
    product_id text,
    product_title text,
    product_description text,
    product_subtitle text,
    product_type text,
    product_collection text,
    product_handle text,
    variant_sku text,
    variant_barcode text,
    variant_title text,
    variant_option_values jsonb,
    requires_shipping boolean DEFAULT true NOT NULL,
    is_discountable boolean DEFAULT true NOT NULL,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    compare_at_unit_price numeric,
    raw_compare_at_unit_price jsonb,
    unit_price numeric NOT NULL,
    raw_unit_price jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    is_custom_price boolean DEFAULT false NOT NULL,
    product_type_id text,
    is_giftcard boolean DEFAULT false NOT NULL
);


--
-- Name: order_line_item_adjustment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_line_item_adjustment (
    id text NOT NULL,
    description text,
    promotion_id text,
    code text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    item_id text NOT NULL,
    deleted_at timestamp with time zone,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    version integer DEFAULT 1 NOT NULL
);


--
-- Name: order_line_item_tax_line; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_line_item_tax_line (
    id text NOT NULL,
    description text,
    tax_rate_id text,
    code text NOT NULL,
    rate numeric NOT NULL,
    raw_rate jsonb NOT NULL,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    item_id text NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order_payment_collection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_payment_collection (
    order_id character varying(255) NOT NULL,
    payment_collection_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order_promotion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_promotion (
    order_id character varying(255) NOT NULL,
    promotion_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order_shipping; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_shipping (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer NOT NULL,
    shipping_method_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    return_id text,
    claim_id text,
    exchange_id text
);


--
-- Name: order_shipping_method; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_shipping_method (
    id text NOT NULL,
    name text NOT NULL,
    description jsonb,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    shipping_option_id text,
    data jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    is_custom_amount boolean DEFAULT false NOT NULL
);


--
-- Name: order_shipping_method_adjustment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_shipping_method_adjustment (
    id text NOT NULL,
    description text,
    promotion_id text,
    code text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    shipping_method_id text NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order_shipping_method_tax_line; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_shipping_method_tax_line (
    id text NOT NULL,
    description text,
    tax_rate_id text,
    code text NOT NULL,
    rate numeric NOT NULL,
    raw_rate jsonb NOT NULL,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    shipping_method_id text NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order_summary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_summary (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    totals jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: order_transaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_transaction (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    currency_code text NOT NULL,
    reference text,
    reference_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    return_id text,
    claim_id text,
    exchange_id text
);


--
-- Name: payment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment (
    id text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    currency_code text NOT NULL,
    provider_id text CONSTRAINT payment_provider_id_not_null1 NOT NULL,
    data jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    captured_at timestamp with time zone,
    canceled_at timestamp with time zone,
    payment_collection_id text NOT NULL,
    payment_session_id text NOT NULL,
    metadata jsonb
);


--
-- Name: payment_collection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_collection (
    id text NOT NULL,
    currency_code text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    authorized_amount numeric,
    raw_authorized_amount jsonb,
    captured_amount numeric,
    raw_captured_amount jsonb,
    refunded_amount numeric,
    raw_refunded_amount jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    completed_at timestamp with time zone,
    status text DEFAULT 'not_paid'::text NOT NULL,
    metadata jsonb,
    CONSTRAINT payment_collection_status_check CHECK ((status = ANY (ARRAY['not_paid'::text, 'awaiting'::text, 'authorized'::text, 'partially_authorized'::text, 'canceled'::text, 'failed'::text, 'partially_captured'::text, 'completed'::text])))
);


--
-- Name: payment_collection_payment_providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_collection_payment_providers (
    payment_collection_id text CONSTRAINT payment_collection_payment_provi_payment_collection_id_not_null NOT NULL,
    payment_provider_id text CONSTRAINT payment_collection_payment_provide_payment_provider_id_not_null NOT NULL
);


--
-- Name: payment_provider; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_provider (
    id text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: payment_session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_session (
    id text NOT NULL,
    currency_code text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    context jsonb,
    status text DEFAULT 'pending'::text NOT NULL,
    authorized_at timestamp with time zone,
    payment_collection_id text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT payment_session_status_check CHECK ((status = ANY (ARRAY['authorized'::text, 'captured'::text, 'pending'::text, 'requires_more'::text, 'error'::text, 'canceled'::text])))
);


--
-- Name: price; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.price (
    id text NOT NULL,
    title text,
    price_set_id text NOT NULL,
    currency_code text CONSTRAINT price_money_amount_id_not_null NOT NULL,
    raw_amount jsonb NOT NULL,
    rules_count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    price_list_id text,
    amount numeric NOT NULL,
    min_quantity numeric,
    max_quantity numeric,
    raw_min_quantity jsonb,
    raw_max_quantity jsonb
);


--
-- Name: price_list; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.price_list (
    id text NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL,
    starts_at timestamp with time zone,
    ends_at timestamp with time zone,
    rules_count integer DEFAULT 0,
    title text NOT NULL,
    description text NOT NULL,
    type text DEFAULT 'sale'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT price_list_status_check CHECK ((status = ANY (ARRAY['active'::text, 'draft'::text]))),
    CONSTRAINT price_list_type_check CHECK ((type = ANY (ARRAY['sale'::text, 'override'::text])))
);


--
-- Name: price_list_rule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.price_list_rule (
    id text NOT NULL,
    price_list_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    value jsonb,
    attribute text DEFAULT ''::text NOT NULL
);


--
-- Name: price_preference; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.price_preference (
    id text NOT NULL,
    attribute text NOT NULL,
    value text,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: price_rule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.price_rule (
    id text NOT NULL,
    value text NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    price_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    attribute text DEFAULT ''::text NOT NULL,
    operator text DEFAULT 'eq'::text NOT NULL,
    CONSTRAINT price_rule_operator_check CHECK ((operator = ANY (ARRAY['gte'::text, 'lte'::text, 'gt'::text, 'lt'::text, 'eq'::text])))
);


--
-- Name: price_set; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.price_set (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: product; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product (
    id text NOT NULL,
    title text NOT NULL,
    handle text NOT NULL,
    subtitle text,
    description text,
    is_giftcard boolean DEFAULT false NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL,
    thumbnail text,
    weight text,
    length text,
    height text,
    width text,
    origin_country text,
    hs_code text,
    mid_code text,
    material text,
    collection_id text,
    type_id text,
    discountable boolean DEFAULT true NOT NULL,
    external_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb,
    CONSTRAINT product_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'proposed'::text, 'published'::text, 'rejected'::text])))
);


--
-- Name: product_category; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_category (
    id text NOT NULL,
    name text NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    handle text NOT NULL,
    mpath text NOT NULL,
    is_active boolean DEFAULT false NOT NULL,
    is_internal boolean DEFAULT false NOT NULL,
    rank integer DEFAULT 0 NOT NULL,
    parent_category_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb
);


--
-- Name: product_category_product; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_category_product (
    product_id text NOT NULL,
    product_category_id text NOT NULL
);


--
-- Name: product_collection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_collection (
    id text NOT NULL,
    title text NOT NULL,
    handle text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: product_option; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_option (
    id text NOT NULL,
    title text NOT NULL,
    product_id text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: product_option_value; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_option_value (
    id text NOT NULL,
    value text NOT NULL,
    option_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: product_sales_channel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_sales_channel (
    product_id character varying(255) NOT NULL,
    sales_channel_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: product_shipping_profile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_shipping_profile (
    product_id character varying(255) NOT NULL,
    shipping_profile_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: product_tag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_tag (
    id text NOT NULL,
    value text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: product_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_tags (
    product_id text NOT NULL,
    product_tag_id text NOT NULL
);


--
-- Name: product_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_type (
    id text NOT NULL,
    value text NOT NULL,
    metadata json,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: product_variant; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_variant (
    id text NOT NULL,
    title text NOT NULL,
    sku text,
    barcode text,
    ean text,
    upc text,
    allow_backorder boolean DEFAULT false NOT NULL,
    manage_inventory boolean DEFAULT true NOT NULL,
    hs_code text,
    origin_country text,
    mid_code text,
    material text,
    weight integer,
    length integer,
    height integer,
    width integer,
    metadata jsonb,
    variant_rank integer DEFAULT 0,
    product_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    thumbnail text
);


--
-- Name: product_variant_inventory_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_variant_inventory_item (
    variant_id character varying(255) NOT NULL,
    inventory_item_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    required_quantity integer DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: product_variant_option; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_variant_option (
    variant_id text NOT NULL,
    option_value_id text NOT NULL
);


--
-- Name: product_variant_price_set; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_variant_price_set (
    variant_id character varying(255) NOT NULL,
    price_set_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: product_variant_product_image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_variant_product_image (
    id text NOT NULL,
    variant_id text NOT NULL,
    image_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: promotion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotion (
    id text NOT NULL,
    code text NOT NULL,
    campaign_id text,
    is_automatic boolean DEFAULT false NOT NULL,
    type text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    status text DEFAULT 'draft'::text NOT NULL,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    "limit" integer,
    used integer DEFAULT 0 NOT NULL,
    metadata jsonb,
    CONSTRAINT promotion_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'active'::text, 'inactive'::text]))),
    CONSTRAINT promotion_type_check CHECK ((type = ANY (ARRAY['standard'::text, 'buyget'::text])))
);


--
-- Name: promotion_application_method; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotion_application_method (
    id text NOT NULL,
    value numeric,
    raw_value jsonb,
    max_quantity integer,
    apply_to_quantity integer,
    buy_rules_min_quantity integer,
    type text NOT NULL,
    target_type text NOT NULL,
    allocation text,
    promotion_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    currency_code text,
    CONSTRAINT promotion_application_method_allocation_check CHECK ((allocation = ANY (ARRAY['each'::text, 'across'::text, 'once'::text]))),
    CONSTRAINT promotion_application_method_target_type_check CHECK ((target_type = ANY (ARRAY['order'::text, 'shipping_methods'::text, 'items'::text]))),
    CONSTRAINT promotion_application_method_type_check CHECK ((type = ANY (ARRAY['fixed'::text, 'percentage'::text])))
);


--
-- Name: promotion_campaign; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotion_campaign (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    campaign_identifier text NOT NULL,
    starts_at timestamp with time zone,
    ends_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: promotion_campaign_budget; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotion_campaign_budget (
    id text NOT NULL,
    type text NOT NULL,
    campaign_id text NOT NULL,
    "limit" numeric,
    raw_limit jsonb,
    used numeric DEFAULT 0 NOT NULL,
    raw_used jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    currency_code text,
    attribute text,
    CONSTRAINT promotion_campaign_budget_type_check CHECK ((type = ANY (ARRAY['spend'::text, 'usage'::text, 'use_by_attribute'::text, 'spend_by_attribute'::text])))
);


--
-- Name: promotion_campaign_budget_usage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotion_campaign_budget_usage (
    id text NOT NULL,
    attribute_value text NOT NULL,
    used numeric DEFAULT 0 NOT NULL,
    budget_id text NOT NULL,
    raw_used jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: promotion_promotion_rule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotion_promotion_rule (
    promotion_id text NOT NULL,
    promotion_rule_id text NOT NULL
);


--
-- Name: promotion_rule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotion_rule (
    id text NOT NULL,
    description text,
    attribute text NOT NULL,
    operator text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT promotion_rule_operator_check CHECK ((operator = ANY (ARRAY['gte'::text, 'lte'::text, 'gt'::text, 'lt'::text, 'eq'::text, 'ne'::text, 'in'::text])))
);


--
-- Name: promotion_rule_value; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promotion_rule_value (
    id text NOT NULL,
    promotion_rule_id text NOT NULL,
    value text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: provider_identity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.provider_identity (
    id text NOT NULL,
    entity_id text NOT NULL,
    provider text NOT NULL,
    auth_identity_id text NOT NULL,
    user_metadata jsonb,
    provider_metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: publishable_api_key_sales_channel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publishable_api_key_sales_channel (
    publishable_key_id character varying(255) NOT NULL,
    sales_channel_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: push_token; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.push_token (
    id text NOT NULL,
    recipient_id text NOT NULL,
    recipient_type text NOT NULL,
    token text NOT NULL,
    device_type text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT push_token_recipient_type_check CHECK ((recipient_type = ANY (ARRAY['customer'::text, 'vendor'::text])))
);


--
-- Name: referral; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.referral (
    id text NOT NULL,
    referrer_customer_id text NOT NULL,
    referred_customer_id text NOT NULL,
    code_used text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    rewarded_at timestamp with time zone,
    referrer_coupon_id text,
    referred_coupon_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT referral_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'rewarded'::text])))
);


--
-- Name: refund; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refund (
    id text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    payment_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by text,
    metadata jsonb,
    refund_reason_id text,
    note text
);


--
-- Name: refund_reason; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refund_reason (
    id text NOT NULL,
    label text NOT NULL,
    description text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    code text NOT NULL
);


--
-- Name: region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.region (
    id text NOT NULL,
    name text NOT NULL,
    currency_code text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    automatic_taxes boolean DEFAULT true NOT NULL
);


--
-- Name: region_country; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.region_country (
    iso_2 text NOT NULL,
    iso_3 text NOT NULL,
    num_code text NOT NULL,
    name text NOT NULL,
    display_name text NOT NULL,
    region_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: region_payment_provider; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.region_payment_provider (
    region_id character varying(255) NOT NULL,
    payment_provider_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: reservation_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reservation_item (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    line_item_id text,
    location_id text NOT NULL,
    quantity numeric NOT NULL,
    external_id text,
    description text,
    created_by text,
    metadata jsonb,
    inventory_item_id text NOT NULL,
    allow_backorder boolean DEFAULT false,
    raw_quantity jsonb
);


--
-- Name: return; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.return (
    id text NOT NULL,
    order_id text NOT NULL,
    claim_id text,
    exchange_id text,
    order_version integer NOT NULL,
    display_id integer NOT NULL,
    status public.return_status_enum DEFAULT 'open'::public.return_status_enum NOT NULL,
    no_notification boolean,
    refund_amount numeric,
    raw_refund_amount jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    received_at timestamp with time zone,
    canceled_at timestamp with time zone,
    location_id text,
    requested_at timestamp with time zone,
    created_by text
);


--
-- Name: return_display_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.return_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: return_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.return_display_id_seq OWNED BY public.return.display_id;


--
-- Name: return_fulfillment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.return_fulfillment (
    return_id character varying(255) NOT NULL,
    fulfillment_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: return_item; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.return_item (
    id text NOT NULL,
    return_id text NOT NULL,
    reason_id text,
    item_id text NOT NULL,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    received_quantity numeric DEFAULT 0 NOT NULL,
    raw_received_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL,
    note text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    damaged_quantity numeric DEFAULT 0 NOT NULL,
    raw_damaged_quantity jsonb DEFAULT '{"value": "0", "precision": 20}'::jsonb NOT NULL
);


--
-- Name: return_reason; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.return_reason (
    id character varying NOT NULL,
    value character varying NOT NULL,
    label character varying NOT NULL,
    description character varying,
    metadata jsonb,
    parent_return_reason_id character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: review; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.review (
    id text NOT NULL,
    product_id text NOT NULL,
    customer_id text NOT NULL,
    rating integer NOT NULL,
    content text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    images jsonb
);


--
-- Name: sales_channel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sales_channel (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    is_disabled boolean DEFAULT false NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: sales_channel_stock_location; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sales_channel_stock_location (
    sales_channel_id character varying(255) NOT NULL,
    stock_location_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: script_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.script_migrations (
    id integer NOT NULL,
    script_name character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    finished_at timestamp with time zone
);


--
-- Name: script_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.script_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: script_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.script_migrations_id_seq OWNED BY public.script_migrations.id;


--
-- Name: service_zone; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.service_zone (
    id text NOT NULL,
    name text NOT NULL,
    metadata jsonb,
    fulfillment_set_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: shipping_option; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipping_option (
    id text NOT NULL,
    name text NOT NULL,
    price_type text DEFAULT 'flat'::text NOT NULL,
    service_zone_id text NOT NULL,
    shipping_profile_id text,
    provider_id text,
    data jsonb,
    metadata jsonb,
    shipping_option_type_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT shipping_option_price_type_check CHECK ((price_type = ANY (ARRAY['calculated'::text, 'flat'::text])))
);


--
-- Name: shipping_option_price_set; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipping_option_price_set (
    shipping_option_id character varying(255) NOT NULL,
    price_set_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: shipping_option_rule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipping_option_rule (
    id text NOT NULL,
    attribute text NOT NULL,
    operator text NOT NULL,
    value jsonb,
    shipping_option_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT shipping_option_rule_operator_check CHECK ((operator = ANY (ARRAY['in'::text, 'eq'::text, 'ne'::text, 'gt'::text, 'gte'::text, 'lt'::text, 'lte'::text, 'nin'::text])))
);


--
-- Name: shipping_option_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipping_option_type (
    id text NOT NULL,
    label text NOT NULL,
    description text,
    code text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: shipping_profile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipping_profile (
    id text NOT NULL,
    name text NOT NULL,
    type text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: short_video; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.short_video (
    id text NOT NULL,
    vendor_id text NOT NULL,
    title text NOT NULL,
    description text,
    video_url text NOT NULL,
    thumbnail_url text,
    duration integer,
    tag text,
    status text DEFAULT 'draft'::text NOT NULL,
    likes_count integer DEFAULT 0 NOT NULL,
    comments_count integer DEFAULT 0 NOT NULL,
    shares_count integer DEFAULT 0 NOT NULL,
    views_count integer DEFAULT 0 NOT NULL,
    product_ids jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    hls_url text,
    is_processed boolean DEFAULT false NOT NULL,
    CONSTRAINT short_video_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'published'::text, 'archived'::text])))
);


--
-- Name: stock_location; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stock_location (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    name text NOT NULL,
    address_id text,
    metadata jsonb
);


--
-- Name: stock_location_address; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stock_location_address (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    address_1 text NOT NULL,
    address_2 text,
    company text,
    city text,
    country_code text NOT NULL,
    phone text,
    province text,
    postal_code text,
    metadata jsonb
);


--
-- Name: store; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.store (
    id text NOT NULL,
    name text DEFAULT 'Medusa Store'::text NOT NULL,
    default_sales_channel_id text,
    default_region_id text,
    default_location_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: store_currency; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.store_currency (
    id text NOT NULL,
    currency_code text NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    store_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: store_locale; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.store_locale (
    id text NOT NULL,
    locale_code text NOT NULL,
    store_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: tax_provider; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tax_provider (
    id text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: tax_rate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tax_rate (
    id text NOT NULL,
    rate real,
    code text NOT NULL,
    name text NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    is_combinable boolean DEFAULT false NOT NULL,
    tax_region_id text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text,
    deleted_at timestamp with time zone
);


--
-- Name: tax_rate_rule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tax_rate_rule (
    id text NOT NULL,
    tax_rate_id text NOT NULL,
    reference_id text NOT NULL,
    reference text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text,
    deleted_at timestamp with time zone
);


--
-- Name: tax_region; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tax_region (
    id text NOT NULL,
    provider_id text,
    country_code text NOT NULL,
    province_code text,
    parent_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text,
    deleted_at timestamp with time zone,
    CONSTRAINT "CK_tax_region_country_top_level" CHECK (((parent_id IS NULL) OR (province_code IS NOT NULL))),
    CONSTRAINT "CK_tax_region_provider_top_level" CHECK (((parent_id IS NULL) OR (provider_id IS NULL)))
);


--
-- Name: translation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.translation (
    id text NOT NULL,
    reference_id text NOT NULL,
    reference text NOT NULL,
    locale_code text NOT NULL,
    translations jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    translated_field_count integer DEFAULT 0 NOT NULL
);


--
-- Name: translation_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.translation_settings (
    id text NOT NULL,
    entity_type text NOT NULL,
    fields jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    is_active boolean DEFAULT true NOT NULL
);


--
-- Name: user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."user" (
    id text NOT NULL,
    first_name text,
    last_name text,
    email text NOT NULL,
    avatar_url text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: user_activity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_activity (
    id text NOT NULL,
    customer_id text NOT NULL,
    action_type text NOT NULL,
    entity_type text,
    entity_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT user_activity_action_type_check CHECK ((action_type = ANY (ARRAY['product_view'::text, 'add_to_cart'::text, 'remove_from_cart'::text, 'wishlist_add'::text, 'wishlist_remove'::text, 'search'::text, 'checkout_step'::text, 'purchase'::text])))
);


--
-- Name: user_preference; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_preference (
    id text NOT NULL,
    user_id text NOT NULL,
    key text NOT NULL,
    value jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: user_rbac_role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_rbac_role (
    user_id character varying(255) NOT NULL,
    rbac_role_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: vendor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vendor (
    id text NOT NULL,
    handle text,
    name text NOT NULL,
    logo text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    cover_image text,
    description text,
    phone text,
    email text,
    website text,
    country text,
    city text,
    address text,
    founded_year integer,
    business_type text,
    main_products text,
    employee_count text,
    social_links jsonb,
    is_verified boolean DEFAULT false NOT NULL,
    response_rate numeric,
    response_time text,
    balance integer DEFAULT 0 NOT NULL
);


--
-- Name: vendor_admin; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vendor_admin (
    id text NOT NULL,
    first_name text,
    last_name text,
    email text NOT NULL,
    vendor_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: vendor_follow; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vendor_follow (
    id text NOT NULL,
    customer_id text NOT NULL,
    vendor_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: vendor_payout; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vendor_payout (
    id text NOT NULL,
    amount integer NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    payment_method text NOT NULL,
    payment_details jsonb NOT NULL,
    rejection_reason text,
    vendor_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT vendor_payout_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text])))
);


--
-- Name: video_comment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.video_comment (
    id text NOT NULL,
    video_id text NOT NULL,
    customer_id text NOT NULL,
    content text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    vendor_id text,
    parent_id text
);


--
-- Name: video_like; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.video_like (
    id text NOT NULL,
    video_id text NOT NULL,
    customer_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: video_save; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.video_save (
    id text NOT NULL,
    video_id text NOT NULL,
    customer_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: view_configuration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.view_configuration (
    id text NOT NULL,
    entity text NOT NULL,
    name text,
    user_id text,
    is_system_default boolean DEFAULT false NOT NULL,
    configuration jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: wheel_prize; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wheel_prize (
    id text NOT NULL,
    label text NOT NULL,
    prize_type text NOT NULL,
    points_value integer,
    coupon_discount_value integer,
    coupon_validity_days integer,
    weight integer DEFAULT 1 NOT NULL,
    color text,
    icon text,
    is_active boolean DEFAULT true NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT wheel_prize_prize_type_check CHECK ((prize_type = ANY (ARRAY['points'::text, 'coupon_percentage'::text, 'coupon_fixed'::text, 'free_shipping'::text, 'no_win'::text])))
);


--
-- Name: wheel_spin; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wheel_spin (
    id text NOT NULL,
    prize_id text NOT NULL,
    spin_date text NOT NULL,
    points_earned integer DEFAULT 0 NOT NULL,
    coupon_id text,
    loyalty_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: workflow_execution; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workflow_execution (
    id character varying NOT NULL,
    workflow_id character varying NOT NULL,
    transaction_id character varying NOT NULL,
    execution jsonb,
    context jsonb,
    state character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    deleted_at timestamp without time zone,
    retention_time integer,
    run_id text DEFAULT '01KSCR4ZFRG0VVQ2X57DPH39W3'::text NOT NULL
);


--
-- Name: link_module_migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link_module_migrations ALTER COLUMN id SET DEFAULT nextval('public.link_module_migrations_id_seq'::regclass);


--
-- Name: mikro_orm_migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mikro_orm_migrations ALTER COLUMN id SET DEFAULT nextval('public.mikro_orm_migrations_id_seq'::regclass);


--
-- Name: order display_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."order" ALTER COLUMN display_id SET DEFAULT nextval('public.order_display_id_seq'::regclass);


--
-- Name: order_change_action ordering; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_change_action ALTER COLUMN ordering SET DEFAULT nextval('public.order_change_action_ordering_seq'::regclass);


--
-- Name: order_claim display_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_claim ALTER COLUMN display_id SET DEFAULT nextval('public.order_claim_display_id_seq'::regclass);


--
-- Name: order_exchange display_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_exchange ALTER COLUMN display_id SET DEFAULT nextval('public.order_exchange_display_id_seq'::regclass);


--
-- Name: return display_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.return ALTER COLUMN display_id SET DEFAULT nextval('public.return_display_id_seq'::regclass);


--
-- Name: script_migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.script_migrations ALTER COLUMN id SET DEFAULT nextval('public.script_migrations_id_seq'::regclass);


--
-- Data for Name: account_holder; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.account_holder (id, provider_id, external_id, email, data, metadata, created_at, updated_at, deleted_at) FROM stdin;
acchld_01KSWZ94HFGMXS8Z8D3YATDQRX	pp_system_default	cus_01KSVPWBFY9T5MZXK47CYD788Q	princelulinda10@gmail.com	{}	\N	2026-05-30 19:35:31.888+02	2026-05-30 19:35:31.888+02	\N
acchld_01KSYNR3BVMPX2V3KKBG485GEQ	pp_system_default	cus_01KSR173ECD4A2AJF6H3R1H2J8	princelulinda32@gmail.com	{}	\N	2026-05-31 11:27:25.307+02	2026-05-31 11:27:25.307+02	\N
acchld_01KT9CPTPVBND0XMSK9CFGCAJH	pp_kashflow_kashflow	cus_01KSR173ECD4A2AJF6H3R1H2J8	princelulinda32@gmail.com	{"customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8"}	\N	2026-06-04 15:21:05.244+02	2026-06-04 15:21:05.244+02	\N
acchld_01KZTFBQKTM9HP0RTPEARR5QAZ	pp_system_default	cus_01KZTFASX63451FWPYQZST4A8M	referraltest_1786521151@example.com	{}	\N	2026-08-12 09:53:01.818+02	2026-08-12 09:53:01.818+02	\N
acchld_01KZV5XB1X9EASGVQNXGVHFYKJ	pp_kashflow_kashflow	cus_01KZV2PTYGTZ4E2VCQ7R28NYVF	princelulinda+2@gmail.com	{"customer_id": "cus_01KZV2PTYGTZ4E2VCQ7R28NYVF"}	\N	2026-08-12 16:27:07.453+02	2026-08-12 16:27:07.453+02	\N
\.


--
-- Data for Name: analytics_event; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.analytics_event (id, product_id, vendor_id, source, campaign, event_type, order_id, created_at, updated_at, deleted_at) FROM stdin;
01KZSS4E9RGAR44K4S7CHB0MGG	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	01KSDE9JVTNAXE0NF67DNVEWBS	order	\N	conversion	order_01KZSS4E0E2TDSQ1CZW34GVH80	2026-08-12 03:24:34.232+02	2026-08-12 03:24:34.232+02	\N
01KZSS71CTECEWNX3A7N388PFX	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	01KSDE9JVTNAXE0NF67DNVEWBS	order	\N	conversion	order_01KZSS713JEJG13A30NW7X2RR7	2026-08-12 03:25:59.323+02	2026-08-12 03:25:59.323+02	\N
01KZSS71D1HP28K79HRGYD4PQV	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	01KSDE9JVTNAXE0NF67DNVEWBS	order	\N	conversion	order_01KZSS713JEJG13A30NW7X2RR7	2026-08-12 03:25:59.329+02	2026-08-12 03:25:59.329+02	\N
01KZSS71D305JMCFRHKR10SA03	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	01KSDE9JVTNAXE0NF67DNVEWBS	order	\N	conversion	order_01KZSS713JEJG13A30NW7X2RR7	2026-08-12 03:25:59.331+02	2026-08-12 03:25:59.331+02	\N
01KZSS71D48KPSHPA1YNYDA7TP	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	01KSDE9JVTNAXE0NF67DNVEWBS	order	\N	conversion	order_01KZSS713JEJG13A30NW7X2RR7	2026-08-12 03:25:59.332+02	2026-08-12 03:25:59.332+02	\N
01KZTFBR45XRXV4JV4GCGXYK7G	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	01KSDE9JVTNAXE0NF67DNVEWBS	order	\N	conversion	order_01KZTFBQSNE8M83ECV3F4F3K9J	2026-08-12 09:53:02.341+02	2026-08-12 09:53:02.341+02	\N
01KZV0DT4M8Q7TBDCG53JZKXS3	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	01KSDE9JVTNAXE0NF67DNVEWBS	direct	\N	click	\N	2026-08-12 14:51:15.733+02	2026-08-12 14:51:15.733+02	\N
01KZV1QY6G01FGJF26C29FJMQS	prod_01KV5DWPN1992BC1RARAP2H0K1	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-12 15:14:16.145+02	2026-08-12 15:14:16.145+02	\N
01KZV2CGMBZ404VTMMY5611PZ3	prod_01KT156V00QYP2NS7HYG4BWMYG	01KSDE9JVTNAXE0NF67DNVEWBS	direct	\N	click	\N	2026-08-12 15:25:30.379+02	2026-08-12 15:25:30.379+02	\N
01KZV2CGMEDA51V25VGCSP6VXQ	prod_01KV5D7S5A3GT3TNV6JJ36QA88	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-12 15:25:30.382+02	2026-08-12 15:25:30.382+02	\N
01KZV2DG4C10YHEQJW0Y2D8XCJ	prod_01KSH2A8YPQ2M4AN368YBJ9X3C	01KSCSTSP7N25SPSF2H5AK45FY	direct	\N	click	\N	2026-08-12 15:26:02.637+02	2026-08-12 15:26:02.637+02	\N
01KZV2YT7GSQBMB263HMGZX5N7	prod_01KT156V00QYP2NS7HYG4BWMYG	01KSDE9JVTNAXE0NF67DNVEWBS	direct	\N	click	\N	2026-08-12 15:35:30.032+02	2026-08-12 15:35:30.032+02	\N
01KZV2YT7HEFGZKN287DFXCBJD	prod_01KV5D7S5A3GT3TNV6JJ36QA88	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-12 15:35:30.034+02	2026-08-12 15:35:30.034+02	\N
01KZV2Z2NNCMQ3Q889800J0BM9	prod_01KSH2A8YPQ2M4AN368YBJ9X3C	01KSCSTSP7N25SPSF2H5AK45FY	direct	\N	click	\N	2026-08-12 15:35:38.677+02	2026-08-12 15:35:38.677+02	\N
01KZV34JS2MNEPTRQ0MJYAFD2Y	prod_01KSH2A8YPQ2M4AN368YBJ9X3C	01KSCSTSP7N25SPSF2H5AK45FY	direct	\N	click	\N	2026-08-12 15:38:39.01+02	2026-08-12 15:38:39.01+02	\N
01KZV456QPJ70FK4YQDF6G20M3	prod_01KSH2A8YPQ2M4AN368YBJ9X3C	01KSCSTSP7N25SPSF2H5AK45FY	direct	\N	click	\N	2026-08-12 15:56:28.023+02	2026-08-12 15:56:28.023+02	\N
01KZV45C6E1CRYS91X811KD80M	prod_01KSH2A8YPQ2M4AN368YBJ9X3C	01KSCSTSP7N25SPSF2H5AK45FY	direct	\N	click	\N	2026-08-12 15:56:33.614+02	2026-08-12 15:56:33.614+02	\N
01KZV45QP1D2JDVJ4F03N22J20	prod_01KV5D7S5A3GT3TNV6JJ36QA88	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-12 15:56:45.377+02	2026-08-12 15:56:45.377+02	\N
01KZV45R1NRKGQ47H5F7D9D9AD	prod_01KT156V00QYP2NS7HYG4BWMYG	01KSDE9JVTNAXE0NF67DNVEWBS	direct	\N	click	\N	2026-08-12 15:56:45.75+02	2026-08-12 15:56:45.75+02	\N
01KZV49QVD9VHP6NDT5DYSC245	prod_01KSH2A8YPQ2M4AN368YBJ9X3C	01KSCSTSP7N25SPSF2H5AK45FY	direct	\N	click	\N	2026-08-12 15:58:56.621+02	2026-08-12 15:58:56.621+02	\N
01KZV4ADAPEXZWBY39SYX4AAYY	prod_01KV5D7S5A3GT3TNV6JJ36QA88	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-12 15:59:18.614+02	2026-08-12 15:59:18.614+02	\N
01KZV4ADQPDRNJQ2DC5JSWFYZD	prod_01KT156V00QYP2NS7HYG4BWMYG	01KSDE9JVTNAXE0NF67DNVEWBS	direct	\N	click	\N	2026-08-12 15:59:19.03+02	2026-08-12 15:59:19.03+02	\N
01KZV4D20D89FJ7WRRG4RQ783D	prod_01KSH2A8YPQ2M4AN368YBJ9X3C	01KSCSTSP7N25SPSF2H5AK45FY	direct	\N	click	\N	2026-08-12 16:00:45.325+02	2026-08-12 16:00:45.325+02	\N
01KZV4DMX4MB0845Z2ZA6Q35GK	prod_01KV5D7S5A3GT3TNV6JJ36QA88	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-12 16:01:04.677+02	2026-08-12 16:01:04.677+02	\N
01KZV4DNHWKQ5M1XTKNNNE5AK0	prod_01KT156V00QYP2NS7HYG4BWMYG	01KSDE9JVTNAXE0NF67DNVEWBS	direct	\N	click	\N	2026-08-12 16:01:05.34+02	2026-08-12 16:01:05.34+02	\N
01KZV4DT41NQGG7M2A9TNS219E	prod_01KSH2A8YPQ2M4AN368YBJ9X3C	01KSCSTSP7N25SPSF2H5AK45FY	direct	\N	click	\N	2026-08-12 16:01:10.017+02	2026-08-12 16:01:10.017+02	\N
01KZV4E1R4K163C14HQNW9HKZX	prod_01KV5D7S5A3GT3TNV6JJ36QA88	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-12 16:01:17.828+02	2026-08-12 16:01:17.828+02	\N
01KZV5Q1KZJ3V03HYBX2NVVRRN	prod_01KWTKZBN13GNZVP6YNBMAD3VP	01KWSMG9MENSKS30A5SCWX8JW2	direct	\N	click	\N	2026-08-12 16:23:41.183+02	2026-08-12 16:23:41.183+02	\N
01KZV5STBAKQ6197WAWMKSN5AX	prod_01KV5D7S5A3GT3TNV6JJ36QA88	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-12 16:25:12.042+02	2026-08-12 16:25:12.042+02	\N
01KZV5TRQ0CE0FF85H6SE5DKFS	prod_01KV5K1Y66BRSD3K4GDMN4M1YS	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-12 16:25:43.136+02	2026-08-12 16:25:43.136+02	\N
01KZV61XGBKDR0GX106C92972E	prod_01KSH2A8YPQ2M4AN368YBJ9X3C	01KSCSTSP7N25SPSF2H5AK45FY	direct	\N	click	\N	2026-08-12 16:29:37.419+02	2026-08-12 16:29:37.419+02	\N
01KZX3CM1WWZYM2XV2601S0Y6P	prod_01KV5DPWQMJ87E724G2PHS05ZZ	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 10:21:31.325+02	2026-08-13 10:21:31.325+02	\N
01KZX3D3NQF30WT4NYRT32QA3V	prod_01KV5H8J0X1ZXZA46EZ0MG683D	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 10:21:47.319+02	2026-08-13 10:21:47.319+02	\N
01KZX3RJBVW1BEF2HDJX70ZR5S	prod_01KV5H8J0X1ZXZA46EZ0MG683D	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 10:28:02.811+02	2026-08-13 10:28:02.811+02	\N
01KZX3RKY2AW76EEZW6PZSXWCK	prod_01KV5H8J0X1ZXZA46EZ0MG683D	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 10:28:04.418+02	2026-08-13 10:28:04.418+02	\N
01KZX3S5PZAQERFD6RCHFNTCX9	prod_01KV5H8J0X1ZXZA46EZ0MG683D	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 10:28:22.624+02	2026-08-13 10:28:22.624+02	\N
01KZX3TRCWYAB6R060X5184YMK	prod_01KV5H8J0X1ZXZA46EZ0MG683D	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 10:29:14.524+02	2026-08-13 10:29:14.524+02	\N
01KZX3TRSVDXNTQBHEZ5G1Z89Z	prod_01KV5H8J0X1ZXZA46EZ0MG683D	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 10:29:14.94+02	2026-08-13 10:29:14.94+02	\N
01KZX3V4JC66GN1D5D6TVV1WVK	prod_01KV5H8J0X1ZXZA46EZ0MG683D	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 10:29:26.988+02	2026-08-13 10:29:26.988+02	\N
01KZX3V584NFQH0Y77QWT51R5C	prod_01KV5H8J0X1ZXZA46EZ0MG683D	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 10:29:27.684+02	2026-08-13 10:29:27.684+02	\N
01KZX3VCEN7RTE5GB734NNG0KP	prod_01KV5H8J0X1ZXZA46EZ0MG683D	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 10:29:35.061+02	2026-08-13 10:29:35.061+02	\N
01KZX3VD4YKGH46CSKXE5DX8MG	prod_01KV5H8J0X1ZXZA46EZ0MG683D	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 10:29:35.775+02	2026-08-13 10:29:35.775+02	\N
01KZX3VENCEYDSFTD1AEN5CXH3	prod_01KV5H8J0X1ZXZA46EZ0MG683D	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 10:29:37.324+02	2026-08-13 10:29:37.324+02	\N
01KZX3VF7SV3EYK93NXHRC6MWM	prod_01KV5H8J0X1ZXZA46EZ0MG683D	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 10:29:37.914+02	2026-08-13 10:29:37.914+02	\N
01KZX3ZY1CWP71RVAV7Z71H937	prod_01KSH2A8YPQ2M4AN368YBJ9X3C	01KSCSTSP7N25SPSF2H5AK45FY	direct	\N	click	\N	2026-08-13 10:32:04.141+02	2026-08-13 10:32:04.141+02	\N
01KZX403B2D06B9FVGN559ZXD5	prod_01KV5D7S5A3GT3TNV6JJ36QA88	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 10:32:09.57+02	2026-08-13 10:32:09.57+02	\N
01KZX42MR9B20ZVCS2Y4E4CQ4F	prod_01KSH2A8YPQ2M4AN368YBJ9X3C	01KSCSTSP7N25SPSF2H5AK45FY	direct	\N	click	\N	2026-08-13 10:33:32.937+02	2026-08-13 10:33:32.937+02	\N
01KZX442Q7W1WJMVANHJ2BBE40	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	01KSDE9JVTNAXE0NF67DNVEWBS	direct	\N	click	\N	2026-08-13 10:34:20.007+02	2026-08-13 10:34:20.007+02	\N
01KZYEBWJXSKQ8SC3A65DFX6DW	prod_01KV5D7S5A3GT3TNV6JJ36QA88	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 22:52:36.062+02	2026-08-13 22:52:36.062+02	\N
01KZYEBXAA29SZV97G86HM5JFB	prod_01KV5D7S5A3GT3TNV6JJ36QA88	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 22:52:36.81+02	2026-08-13 22:52:36.81+02	\N
01KZYEDJE8AMQG7NPKCDPWM45X	prod_01KV5D7S5A3GT3TNV6JJ36QA88	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 22:53:31.208+02	2026-08-13 22:53:31.208+02	\N
01KZYEGMF9P2MA29CBBS03CRDS	prod_01KV5D7S5A3GT3TNV6JJ36QA88	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 22:55:11.593+02	2026-08-13 22:55:11.593+02	\N
01KZYEGMJRP91MBA0HB61VXGSX	prod_01KSH2A8YPQ2M4AN368YBJ9X3C	01KSCSTSP7N25SPSF2H5AK45FY	direct	\N	click	\N	2026-08-13 22:55:11.704+02	2026-08-13 22:55:11.704+02	\N
01KZYEHMQEYJ9Y7TZTSV2ZHQ62	prod_01KV5DPWQMJ87E724G2PHS05ZZ	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 22:55:44.622+02	2026-08-13 22:55:44.622+02	\N
01KZYEMAHAJ7WJ7FV9RVCPSQNX	prod_01KV5D7S5A3GT3TNV6JJ36QA88	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 22:57:12.49+02	2026-08-13 22:57:12.49+02	\N
01KZYEWB8JPVY89M2AZ9D6V92Y	prod_01KV5DPWQMJ87E724G2PHS05ZZ	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 23:01:35.378+02	2026-08-13 23:01:35.378+02	\N
01KZYEWXGBPSDN2ANTRG8R9JWK	prod_01KVAHVT1115P37Z781SCQWX1W	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 23:01:54.06+02	2026-08-13 23:01:54.06+02	\N
01KZYEX7YS6SGHXN824S0D06DP	prod_01KVANBHYVPHYHTH3VKVZDF1VJ	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 23:02:04.761+02	2026-08-13 23:02:04.761+02	\N
01KZYEXFFFYCDGN223HNENDCXB	prod_01KV5E601185BKG901X7QG2CEW	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 23:02:12.463+02	2026-08-13 23:02:12.463+02	\N
01KZYEXQ0E72F028C30P86K0XD	prod_01KV5K1Y66BRSD3K4GDMN4M1YS	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-13 23:02:20.174+02	2026-08-13 23:02:20.174+02	\N
01M015FEDB37QXYZRBRW5HW870	prod_01KVAHVT1115P37Z781SCQWX1W	01KV5CHYWYZVSNYGB0RXEYG5CK	direct	\N	click	\N	2026-08-15 00:14:58.731+02	2026-08-15 00:14:58.731+02	\N
01M02ASJRP7Z7VWCPH8X7BMP6W	prod_01KV5D7S5A3GT3TNV6JJ36QA88	01KV5CHYWYZVSNYGB0RXEYG5CK	localhost	\N	click	\N	2026-08-15 11:07:08.182+02	2026-08-15 11:07:08.182+02	\N
01M02EN9YXGNM9E056MYCV9107	prod_01KV5K1Y66BRSD3K4GDMN4M1YS	01KV5CHYWYZVSNYGB0RXEYG5CK	localhost	\N	click	\N	2026-08-15 12:14:42.398+02	2026-08-15 12:14:42.398+02	\N
01M035EV7RS1TS40VME1RHJ2RT	prod_01KV5DWPN1992BC1RARAP2H0K1	01KV5CHYWYZVSNYGB0RXEYG5CK	localhost	\N	click	\N	2026-08-15 18:53:07.961+02	2026-08-15 18:53:07.961+02	\N
01M035F84TD9M17BDYHQTBWBBB	prod_01KV5K1Y66BRSD3K4GDMN4M1YS	01KV5CHYWYZVSNYGB0RXEYG5CK	localhost	\N	click	\N	2026-08-15 18:53:21.178+02	2026-08-15 18:53:21.178+02	\N
01M03BP6KDV90WG4MT56QYYY7A	prod_01KT156V00QYP2NS7HYG4BWMYG	01KSDE9JVTNAXE0NF67DNVEWBS	localhost	\N	click	\N	2026-08-15 20:42:00.429+02	2026-08-15 20:42:00.429+02	\N
01M03BV8J2HSSM8QJTNHQJNQM1	prod_01KSH2A8YPQ2M4AN368YBJ9X3C	01KSCSTSP7N25SPSF2H5AK45FY	localhost	\N	click	\N	2026-08-15 20:44:46.274+02	2026-08-15 20:44:46.274+02	\N
01M03C67ZTFZY17P63591X0F97	prod_01KVAHVT1115P37Z781SCQWX1W	01KV5CHYWYZVSNYGB0RXEYG5CK	localhost	\N	click	\N	2026-08-15 20:50:46.139+02	2026-08-15 20:50:46.139+02	\N
\.


--
-- Data for Name: api_key; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.api_key (id, token, salt, redacted, title, type, last_used_at, created_by, created_at, revoked_by, revoked_at, updated_at, deleted_at) FROM stdin;
apk_01KSCR9E4FPV3BZ6DTK9AQ9BCY	pk_9724ff03c87a78bd61b95498bd9e7fcad29484f546c654dcc1338ec68950f2d9		pk_972***2d9	Default Publishable API Key	publishable	\N		2026-05-24 12:25:30.767+02	\N	\N	2026-05-24 12:25:30.767+02	\N
apk_01KSCR9E9G4ZV5ENRXW1WS8XVC	pk_a7da09f6f330376b3513174f9a761990e8c0bba3c0563ba0efb4146f5db0458f		pk_a7d***58f	Webshop	publishable	\N		2026-05-24 12:25:30.928+02	\N	\N	2026-05-24 12:25:30.928+02	\N
\.


--
-- Data for Name: app_notification; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.app_notification (id, recipient_id, recipient_type, type, title, body, data, is_read, created_at, updated_at, deleted_at) FROM stdin;
01KSWZ9527TZ75D33H6QZD0DS7	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_order	Nouvelle commande	Vous avez reçu une nouvelle commande #1.	{"order_id": "order_01KSWZ94QHBKV096ESCTPKNS2N", "display_id": 1}	f	2026-05-30 19:35:32.423+02	2026-05-30 19:35:32.423+02	\N
01KSWZ9521570XZXM4KSN7X06A	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_order	Commande confirmée	Votre commande #1 a été confirmée.	{"order_id": "order_01KSWZ94QHBKV096ESCTPKNS2N", "display_id": 1}	t	2026-05-30 19:35:32.418+02	2026-05-31 09:19:14.986+02	\N
01KSYGK353126BG88E05WZX1H6	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	order_shipped	Commande expédiée	Votre commande #1 est en route !	{"order_id": "order_01KSWZ94QHBKV096ESCTPKNS2N", "display_id": 1}	t	2026-05-31 09:57:18.371+02	2026-05-31 10:01:23.813+02	\N
01KSYNR3JT263D03829WB48B9T	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_order	Commande confirmée	Votre commande #2 a été confirmée.	{"order_id": "order_01KSYNR3FQYDZ176SCBXMTC2CA", "display_id": 2}	f	2026-05-31 11:27:25.53+02	2026-05-31 11:27:25.53+02	\N
01KSYNR3JWZH9BHQMA1ZHBEQ14	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_order	Nouvelle commande	Vous avez reçu une nouvelle commande #2.	{"order_id": "order_01KSYNR3FQYDZ176SCBXMTC2CA", "display_id": 2}	f	2026-05-31 11:27:25.532+02	2026-05-31 11:27:25.532+02	\N
01KSYNRY77XT1KZTGQGVVEZS3E	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	order_shipped	Commande expédiée	Votre commande #2 est en route !	{"order_id": "order_01KSYNR3FQYDZ176SCBXMTC2CA", "display_id": 2}	f	2026-05-31 11:27:52.807+02	2026-05-31 11:27:52.807+02	\N
01KSYPW2WH411FCB66XNMBBS2D	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_order	Commande confirmée	Votre commande #3 a été confirmée.	{"order_id": "order_01KSYPW2RSZ248CCQ1F6HZEQJ5", "display_id": 3}	f	2026-05-31 11:47:04.465+02	2026-05-31 11:47:04.465+02	\N
01KSYPW2WKBSQBYFTM8T5QTS7W	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_order	Nouvelle commande	Vous avez reçu une nouvelle commande #3.	{"order_id": "order_01KSYPW2RSZ248CCQ1F6HZEQJ5", "display_id": 3}	f	2026-05-31 11:47:04.467+02	2026-05-31 11:47:04.467+02	\N
01KSYPWSH8FZB5M3N9JZKY9XMH	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	order_shipped	Commande expédiée	Votre commande #3 est en route !	{"order_id": "order_01KSYPW2RSZ248CCQ1F6HZEQJ5", "display_id": 3}	f	2026-05-31 11:47:27.656+02	2026-05-31 11:47:27.656+02	\N
01KSYZ52D3298AHE9782ABMSFE	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_order	Nouvelle commande	Vous avez reçu une nouvelle commande #4.	{"order_id": "order_01KSYZ528J6XCKJY7DR20SPNTZ", "display_id": 4}	f	2026-05-31 14:11:47.491+02	2026-05-31 14:11:47.491+02	\N
01KSYZ9NPXJX4RSXG8XMAAE336	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_order	Commande confirmée	Votre commande #5 a été confirmée.	{"order_id": "order_01KSYZ9NKNR0ZFP1NHRRJ6C4H0", "display_id": 5}	f	2026-05-31 14:14:18.333+02	2026-05-31 14:14:18.333+02	\N
01KSYZ9NPZECEZ0S7T8FYSV529	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_order	Nouvelle commande	Vous avez reçu une nouvelle commande #5.	{"order_id": "order_01KSYZ9NKNR0ZFP1NHRRJ6C4H0", "display_id": 5}	f	2026-05-31 14:14:18.335+02	2026-05-31 14:14:18.335+02	\N
01KSYZEHF1W4E6FYAZZ6RZEJMM	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_order	Commande confirmée	Votre commande #6 a été confirmée.	{"order_id": "order_01KSYZEHBJT6J0R02PCEWAQXYW", "display_id": 6}	f	2026-05-31 14:16:57.825+02	2026-05-31 14:16:57.825+02	\N
01KSYZEHF4KN5PBHHBP7ZMJTC1	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_order	Nouvelle commande	Vous avez reçu une nouvelle commande #6.	{"order_id": "order_01KSYZEHBJT6J0R02PCEWAQXYW", "display_id": 6}	f	2026-05-31 14:16:57.828+02	2026-05-31 14:16:57.828+02	\N
01KSZ025F59WG1DS4KTZFA4VW8	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_order	Commande confirmée	Votre commande #7 a été confirmée.	{"order_id": "order_01KSZ025ATTT8ABSP8NXJK5XXH", "display_id": 7}	f	2026-05-31 14:27:40.901+02	2026-05-31 14:27:40.901+02	\N
01KSZ025F8QSNNG0FRG11CNMV7	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_order	Nouvelle commande	Vous avez reçu une nouvelle commande #7.	{"order_id": "order_01KSZ025ATTT8ABSP8NXJK5XXH", "display_id": 7}	f	2026-05-31 14:27:40.904+02	2026-05-31 14:27:40.904+02	\N
01KSZ040VBE9NC22F32KMEQN8G	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_order	Commande confirmée	Votre commande #8 a été confirmée.	{"order_id": "order_01KSZ040QG8CAWV63TQC132B9P", "display_id": 8}	f	2026-05-31 14:28:41.707+02	2026-05-31 14:28:41.707+02	\N
01KSZ040VE226TQESFMYP0C6KK	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_order	Nouvelle commande	Vous avez reçu une nouvelle commande #8.	{"order_id": "order_01KSZ040QG8CAWV63TQC132B9P", "display_id": 8}	f	2026-05-31 14:28:41.71+02	2026-05-31 14:28:41.71+02	\N
01KSZ0VB4V59EBAZQZ401RM1WX	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_order	Commande confirmée	Votre commande #9 a été confirmée.	{"order_id": "order_01KSZ0VB193K4QY97BW6PNNHWE", "display_id": 9}	f	2026-05-31 14:41:25.915+02	2026-05-31 14:41:25.915+02	\N
01KSZ0VB4XNEW8WP7CKB0KXQ2R	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_order	Nouvelle commande	Vous avez reçu une nouvelle commande #9.	{"order_id": "order_01KSZ0VB193K4QY97BW6PNNHWE", "display_id": 9}	f	2026-05-31 14:41:25.918+02	2026-05-31 14:41:25.918+02	\N
01KSZ1DJQ5KF1MCPH0XZXAQ0ZZ	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Delivery time?	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-05-31 14:51:23.494+02	2026-05-31 14:51:23.494+02	\N
01KSZ1EEJEY1DM4HJHFG5KK4G5	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	What is the price?	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-05-31 14:51:52.014+02	2026-05-31 14:51:52.014+02	\N
01KSZ1FBSQTD8VMH0MWJCCZZ5J	cus_01KSDGQE4N7DEJ0C3Q810Y8CYP	customer	new_message	Nouveau message	Je	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSDJSH13J278RNCTA18TBV4D"}	f	2026-05-31 14:52:21.943+02	2026-05-31 14:52:21.943+02	\N
01KSZ71V484PY56XEAQ8MA7HK7	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Hello	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-05-31 16:29:50.344+02	2026-05-31 16:29:50.344+02	\N
01KSZ735S1GQ57VC04ZXDGZ13C	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Hello	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-05-31 16:30:34.018+02	2026-05-31 16:30:34.018+02	\N
01KSZ76DH420AFJTRXBN6VGCW9	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Mmmm	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-05-31 16:32:20.26+02	2026-05-31 16:32:20.26+02	\N
01KSZ87JC1X42XTM92BFH4YCZY	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Hé	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-05-31 16:50:26.561+02	2026-05-31 16:50:26.561+02	\N
01KSZ892YY8PBFAVA3AZ950XKJ	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Jjjjjj	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-05-31 16:51:16.319+02	2026-05-31 16:51:16.319+02	\N
01KSZ8AQ6JVPPXP2S1JT56VQPR	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	What is the price?	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-05-31 16:52:09.81+02	2026-05-31 16:52:09.81+02	\N
01KSZ8B42E8XZMHXS6D07JEY5X	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Hhhhhj	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-05-31 16:52:22.991+02	2026-05-31 16:52:22.991+02	\N
01KSZ8DGBKM1XV3KYC9RNFGNE4	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	💡 Conseil pratique pour les langues africaines :\nIl est souvent préférable de créer ton propre data	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-05-31 16:53:41.107+02	2026-05-31 16:53:41.107+02	\N
01KSZ8E3SYZE02WZ57ARXCRN3B	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	💡 Conseil pratique pour les langues africaines :\nIl est souvent préférable de créer ton propre data	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-05-31 16:54:01.023+02	2026-05-31 16:54:01.023+02	\N
01KSZ8FSJC503F5G65YCAXGHSQ	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	💡 Conseil pratique pour les langues africaines :\nIl est souvent préférable de créer ton propre data	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-05-31 16:54:56.077+02	2026-05-31 16:54:56.077+02	\N
01KSZAJ1RFB7QPHD7E1HB0M8M2	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Bonjour, est-ce disponible ?	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-05-31 17:31:07.151+02	2026-05-31 17:31:07.151+02	\N
01KSZAMWF50WCN6WPCE8BTJBZ8	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Pouvez-vous m'accorder une remise ?	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-05-31 17:32:40.037+02	2026-05-31 17:32:40.037+02	\N
01KSZANCV034XKS1EE4ND3YQNQ	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Nnn	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-05-31 17:32:56.8+02	2026-05-31 17:32:56.8+02	\N
01KSZAPGZ9YT15E2EJKEPSYPM7	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Combien coûte la livraison ?hh	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-05-31 17:33:33.801+02	2026-05-31 17:33:33.801+02	\N
01KSZAQRZ5ZNZAPT1TMPKT1B2Z	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Bonjour	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-05-31 17:34:14.758+02	2026-05-31 17:34:14.758+02	\N
01KSZAMMTXJNQGGB2JJV5HTJ84	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Bonjour \nJe ne sais	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	t	2026-05-31 17:32:32.221+02	2026-05-31 17:34:47.77+02	\N
01KSZAYDHMYBJ1MX8SCYF8M74F	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	🙂‍↔️	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-05-31 17:37:52.436+02	2026-05-31 17:37:52.436+02	\N
01KSZBEZHTSS9MB100SNBF4K1E	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Hhhhjjjjjjjjjj	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-05-31 17:46:55.162+02	2026-05-31 17:46:55.162+02	\N
01KSZBMBM9Z47JZSQC7CEE8SJF	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Bonjour, est-ce disponible ?	{"sender_id": "cus_01KSWS7V39C4SDB1YTY9K83SMS", "sender_type": "customer", "conversation_id": "01KSZBM4SAZPVEQAZMQZFZ5NXG"}	f	2026-05-31 17:49:51.369+02	2026-05-31 17:49:51.369+02	\N
01KSZBN16FTG7VK0TJ8996JMFY	cus_01KSWS7V39C4SDB1YTY9K83SMS	customer	new_message	Nouveau message	Hello	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSZBM4SAZPVEQAZMQZFZ5NXG"}	f	2026-05-31 17:50:13.455+02	2026-05-31 17:50:13.455+02	\N
01KSZBQDB3HT8BZ79QW2NZ8SCV	cus_01KSWS7V39C4SDB1YTY9K83SMS	customer	new_message	Nouveau message	Mmm	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSZBM4SAZPVEQAZMQZFZ5NXG"}	f	2026-05-31 17:51:31.427+02	2026-05-31 17:51:31.427+02	\N
01KSZCB0VJ0RMH9QPACERXGR6K	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Bonjour, est-ce disponible ?	{"sender_id": "cus_01KSVPWBFY9T5MZXK47CYD788Q", "sender_type": "customer", "conversation_id": "01KSZCADYC4Z7KN64BXJ5023R1"}	f	2026-05-31 18:02:14.002+02	2026-05-31 18:02:14.002+02	\N
01KSZCCDCGMV8QJ7KZGVRBH14J	cus_01KSVPWBFY9T5MZXK47CYD788Q	customer	new_message	Nouveau message	Pi	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSZCADYC4Z7KN64BXJ5023R1"}	f	2026-05-31 18:02:59.6+02	2026-05-31 18:02:59.6+02	\N
01KSZCDGWR261Z9AH6YNPD82NE	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Bonjour, est-ce disponible ?	{"sender_id": "cus_01KSVPWBFY9T5MZXK47CYD788Q", "sender_type": "customer", "conversation_id": "01KSZCADYC4Z7KN64BXJ5023R1"}	f	2026-05-31 18:03:35.96+02	2026-05-31 18:03:35.96+02	\N
01KSZCDSV0XY7E3V3E39JMB36Z	cus_01KSVPWBFY9T5MZXK47CYD788Q	customer	new_message	Nouveau message	Nnnnn	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSZCADYC4Z7KN64BXJ5023R1"}	f	2026-05-31 18:03:45.12+02	2026-05-31 18:03:45.12+02	\N
01KSZCG5B6YESH3XD2JYRSHY1F	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Quel est le meilleur prix ?	{"sender_id": "cus_01KSVPWBFY9T5MZXK47CYD788Q", "sender_type": "customer", "conversation_id": "01KSZCADYC4Z7KN64BXJ5023R1"}	f	2026-05-31 18:05:02.438+02	2026-05-31 18:05:02.438+02	\N
01KSZCPYTY5KM0GASASPA8ADHP	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Quel est le meilleur prix ?	{"sender_id": "cus_01KSVPWBFY9T5MZXK47CYD788Q", "sender_type": "customer", "conversation_id": "01KSZCADYC4Z7KN64BXJ5023R1"}	f	2026-05-31 18:08:45.151+02	2026-05-31 18:08:45.151+02	\N
01KSZCVVMMBCS62FX213GBCDQE	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Quel est le meilleur prix ?	{"sender_id": "cus_01KSVPWBFY9T5MZXK47CYD788Q", "sender_type": "customer", "conversation_id": "01KSZCADYC4Z7KN64BXJ5023R1"}	f	2026-05-31 18:11:25.716+02	2026-05-31 18:11:25.716+02	\N
01KSZD4ZKCQNRP5RPW8SH672FH	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Quel est le meilleur prix ?	{"sender_id": "cus_01KSVPWBFY9T5MZXK47CYD788Q", "sender_type": "customer", "conversation_id": "01KSZCADYC4Z7KN64BXJ5023R1"}	f	2026-05-31 18:16:24.684+02	2026-05-31 18:16:24.684+02	\N
01KSZE8M5M0MPEWC8Y85D2CGZT	cus_01KSVPWBFY9T5MZXK47CYD788Q	customer	new_message	Nouveau message	Ooooop	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSZCADYC4Z7KN64BXJ5023R1"}	f	2026-05-31 18:35:52.628+02	2026-05-31 18:35:52.628+02	\N
01KSZQ5SMS3PN2T0CK2PFF605D	cus_01KSVPWBFY9T5MZXK47CYD788Q	customer	new_message	Nouveau message	Hello	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSZCADYC4Z7KN64BXJ5023R1"}	f	2026-05-31 21:11:37.114+02	2026-05-31 21:11:37.114+02	\N
01KT01EMN1TY0DQ8XQDMRYJ89C	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Bonjour, est-ce disponible ?	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 00:11:12.673+02	2026-06-01 00:11:12.673+02	\N
01KT01G842M45353D8PDFMEGW0	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Oooo	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 00:12:05.378+02	2026-06-01 00:12:05.378+02	\N
01KT01H61H7EE97PZNJA2W553Z	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Quel est le meilleur prix ?	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 00:12:36.018+02	2026-06-01 00:12:36.018+02	\N
01KT02SSGSSHN8PVJ4CQKV8YZZ	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Nnnn	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 00:34:46.681+02	2026-06-01 00:34:46.681+02	\N
01KT03763RQZQW5ZSE4C7JKC0H	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Iiii	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 00:42:05.56+02	2026-06-01 00:42:05.56+02	\N
01KT038K5VY6WEF2QX51397DDE	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Bonjour, est-ce disponible ?	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 00:42:51.708+02	2026-06-01 00:42:51.708+02	\N
01KT03FQXVWR46V9C6H40RVMH3	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Ggg	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 00:46:45.948+02	2026-06-01 00:46:45.948+02	\N
01KT059HWHG53F877VNSZAK3AZ	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Bonjour, est-ce disponible ?	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 01:18:20.306+02	2026-06-01 01:18:20.306+02	\N
01KT067TBS73MTNQB7ZF3XSYYE	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Bonjour, est-ce disponible ?	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 01:34:52.025+02	2026-06-01 01:34:52.025+02	\N
01KT0698YFSCRC0FD6CNSG0NS3	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Bonjour, est-ce disponible ?	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 01:35:39.728+02	2026-06-01 01:35:39.728+02	\N
01KT06BA2HSCJSJQ1QVT4338VW	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Bonjour, est-ce disponible ?	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 01:36:46.418+02	2026-06-01 01:36:46.418+02	\N
01KT06CD6TX386D9ZTSSZPRS0M	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Hjjjjjkk	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 01:37:22.394+02	2026-06-01 01:37:22.394+02	\N
01KT06CW4N2P1WRMXTWW25XT23	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Iijjjj	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 01:37:37.685+02	2026-06-01 01:37:37.685+02	\N
01KT06D6WR4TFQ0T72ZFPTN4XP	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Jjjnjj	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 01:37:48.696+02	2026-06-01 01:37:48.696+02	\N
01KT06DWAM534KYAZA9KAA518Z	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Bonjour, est-ce disponible ?	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 01:38:10.645+02	2026-06-01 01:38:10.645+02	\N
01KT06H6WJNMCEGJSARAW6W92Z	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Papa	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 01:39:59.762+02	2026-06-01 01:39:59.762+02	\N
01KT06QAVWF5R9XCQB45GENQBM	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Quel est le meilleur prix ?	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 01:43:20.445+02	2026-06-01 01:43:20.445+02	\N
01KT071W61VK8ZMCKGFGH6Z54W	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Mama	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 01:49:05.857+02	2026-06-01 01:49:05.857+02	\N
01KT07KGCZC9X2PG4Y75YP942X	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Hhh	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 01:58:43.615+02	2026-06-01 01:58:43.615+02	\N
01KT07KXQ1TGGXR19XV3501ZKE	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Bonjour, est-ce disponible ?	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 01:58:57.249+02	2026-06-01 01:58:57.249+02	\N
01KT07P2878VEJ0B5C4K7QCEVJ	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Hello	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 02:00:07.432+02	2026-06-01 02:00:07.432+02	\N
01KT07Q1ET88M6QWBT4HNDG1D8	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Kjjjjjjjjjhhhjkkjhhhggggggggggghhh	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 02:00:39.387+02	2026-06-01 02:00:39.387+02	\N
01KT08262WWG2JTX3H5J9Q05R3	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Mmm	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 02:06:44.573+02	2026-06-01 02:06:44.573+02	\N
01KT0849RS9NMVG3VQPPE6765A	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Quel est le meilleur prix ?	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 02:07:53.881+02	2026-06-01 02:07:53.881+02	\N
01KT08EHAPKP7WEP6VASV0BMZY	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Quel est le meilleur prix ?	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 02:13:29.303+02	2026-06-01 02:13:29.303+02	\N
01KT08H9S8PWM9MRG4A0ZNAD3P	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Bonjour, est-ce disponible ?	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 02:14:59.88+02	2026-06-01 02:14:59.88+02	\N
01KT08KM0R0C19QA4W5NVH2HMK	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Pouvez-vous m'accorder une remise ?	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 02:16:15.896+02	2026-06-01 02:16:15.896+02	\N
01KT08M36CZHQC2FESNMAD6SR0	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Nnn	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 02:16:31.436+02	2026-06-01 02:16:31.436+02	\N
01KT08M36NJDG6THZ2ZJQX3F1C	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Nnn	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 02:16:31.446+02	2026-06-01 02:16:31.446+02	\N
01KT08VEF5CFZ8EYN20CC7ZQKQ	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Uu	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 02:20:32.357+02	2026-06-01 02:20:32.357+02	\N
01KT08XKBFFFJHBPE3J8ZSY4W7	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Hhh	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 02:21:42.895+02	2026-06-01 02:21:42.895+02	\N
01KT08YB8H4W54AX0T8AXG17G4	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	No	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 02:22:07.378+02	2026-06-01 02:22:07.378+02	\N
01KT090YNFVTEPS1MMNC19J6MT	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Jjjjj	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 02:23:32.783+02	2026-06-01 02:23:32.783+02	\N
01KT0959KT53DWMH1QZXVKHCZ6	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Bbbbn	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 02:25:55.066+02	2026-06-01 02:25:55.066+02	\N
01KT095ZBJS3BV0PW0JWS2JMFN	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Bonjour, est-ce disponible ?	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 02:26:17.33+02	2026-06-01 02:26:17.33+02	\N
01KT0ACTNK41FMTWWYX9WG9GYS	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Aws	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 02:47:30.483+02	2026-06-01 02:47:30.483+02	\N
01KT0AFYRC23ECJCXGVG13C4EE	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Oooo	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 02:49:12.972+02	2026-06-01 02:49:12.972+02	\N
01KT0AXPJZ4ANM4NP6JM9Q4APM	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Bonjour, est-ce disponible ?	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 02:56:43.359+02	2026-06-01 02:56:43.359+02	\N
01KT0B05M8M334E7H2WBWHRQ68	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Quel est le meilleur prix ?	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 02:58:04.297+02	2026-06-01 02:58:04.297+02	\N
01KT0B34NGB403EHNKRKN441HC	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Pouvez-vous m'accorder une remise ?	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 02:59:41.616+02	2026-06-01 02:59:41.616+02	\N
01KT0B4GQYHYKKNZTMF60M69H5	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Kkk	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 03:00:26.75+02	2026-06-01 03:00:26.75+02	\N
01KT0B56Z3JQMTRNMHCG9301PG	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Nnn	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 03:00:49.507+02	2026-06-01 03:00:49.507+02	\N
01KT0B664NT3VVJHS8VYSBW431	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Nnjj	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 03:01:21.429+02	2026-06-01 03:01:21.429+02	\N
01KT0B6YHJXXN96CY31HN0ZS6Y	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Mmmm	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 03:01:46.418+02	2026-06-01 03:01:46.418+02	\N
01KT0B7B60Q98MY0NTENDYHPRN	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Jkk	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 03:01:59.36+02	2026-06-01 03:01:59.36+02	\N
01KT0B82SEQSSEPG6T9361E1XF	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Kkk	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 03:02:23.534+02	2026-06-01 03:02:23.534+02	\N
01KT0B8VY7EP6HWSKPJACFDVAB	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Kik	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 03:02:49.287+02	2026-06-01 03:02:49.287+02	\N
01KT0BDK4X1CWCFEDHJMQVWQF4	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Kkkk	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 03:05:24.125+02	2026-06-01 03:05:24.125+02	\N
01KT0CRGBFRAQCQYYSJMF06C1R	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Bonjour	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 03:28:50.287+02	2026-06-01 03:28:50.287+02	\N
01KT0D5C5MKWAMVMQDC1Q5QXNX	01KSCS6FH5H9J6QY6ZPJ0110W5	vendor	new_message	Nouveau message	Quel est le meilleur prix ?	{"sender_id": "cus_01KSVPWBFY9T5MZXK47CYD788Q", "sender_type": "customer", "conversation_id": "01KSVVRRD4M51QGFJ12RKZN3V3"}	f	2026-06-01 03:35:51.988+02	2026-06-01 03:35:51.988+02	\N
01KT0D6HX9CP16ESE63W6XR40T	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Bonjour, est-ce disponible ?	{"sender_id": "cus_01KSVPWBFY9T5MZXK47CYD788Q", "sender_type": "customer", "conversation_id": "01KSZCADYC4Z7KN64BXJ5023R1"}	f	2026-06-01 03:36:30.633+02	2026-06-01 03:36:30.633+02	\N
01KT0DH527YG1P2YNPBPN1FJTR	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Quel est le meilleur prix ?	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 03:42:17.928+02	2026-06-01 03:42:17.928+02	\N
01KT0EYR0NH661PR48W2W31VG6	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message		{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 04:07:11.893+02	2026-06-01 04:07:11.893+02	\N
01KT13RKK9Q78873RYC8CRZ72M	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Bb	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 10:10:50.857+02	2026-06-01 10:10:50.857+02	\N
01KT0DJBMTE2T66TY8EACVCFHT	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message		{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	t	2026-06-01 03:42:57.435+02	2026-06-01 10:18:19.833+02	\N
01KT1D3TGHD6Q937DAE15QQZNC	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Bonjour	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 12:54:15.569+02	2026-06-01 12:54:15.569+02	\N
01KT1DGQ2MTAXBWT80T20N9F98	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Hhhh	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 13:01:18.036+02	2026-06-01 13:01:18.036+02	\N
01KTEDDA6X9PRPZANZDRWSB36H	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_review	Nouveau avis	Un client a laissé un avis de 3 étoiles sur votre produit.	{"review_id": "01KTEDDA6QZ1PC9D4NF4H10JMD", "product_id": "prod_01KSDEEB3Y6W05F6K2ZV4GC0BM"}	f	2026-06-06 14:09:34.173+02	2026-06-06 14:09:34.173+02	\N
01KTEEM5NV7SDK47K4RR5629NZ	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Bo\n\n📦 Mapapa - 150 EUR	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-06 14:30:47.483+02	2026-06-06 14:30:47.483+02	\N
01KTFXC31JZMVJWFFC4CJYNEGR	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Bo	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-07 04:07:45.714+02	2026-06-07 04:07:45.714+02	\N
01KTFXGTSFQF6Q5KGSC1K7CE0Y	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Bonjour	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-07 04:10:21.103+02	2026-06-07 04:10:21.103+02	\N
01KW3DGBWMN7KF3FY4S4D646YF	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	bonjour	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-27 04:10:59.093+02	2026-06-27 04:10:59.093+02	\N
01KT1D5461DPDVJTCFG241N0EE	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Hello	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	t	2026-06-01 12:54:58.241+02	2026-06-30 18:27:41.157+02	\N
01KT1D4MZ2BK660FH04AXMYF3D	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	No	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	t	2026-06-01 12:54:42.659+02	2026-06-30 18:31:13.126+02	\N
01KSYZ52D15BNWAVC1826G4FP6	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_order	Commande confirmée	Votre commande #4 a été confirmée.	{"order_id": "order_01KSYZ528J6XCKJY7DR20SPNTZ", "display_id": 4}	t	2026-05-31 14:11:47.489+02	2026-06-30 18:31:19.428+02	\N
01KXDJVHT6WQ95SBW4XJYTZ8XV	01KV5CHYWYZVSNYGB0RXEYG5CK	vendor	new_message	Nouveau message	bonjour!	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KVAQ8F8QB8M9CP6908W8S37S"}	f	2026-07-13 13:12:34.631+02	2026-07-13 13:12:34.631+02	\N
01KXDK36ZTTSNE7VF5RS1SVVBT	01KSCSTSP7N25SPSF2H5AK45FY	vendor	new_message	Nouveau message	Je peux le faire, mais j'ai besoin de l'image elle-même.\n\nLe lien que tu as fourni (`https://www.eas	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSRC31WGAE8QWZC9PM6RMS3Y"}	f	2026-07-13 13:16:45.691+02	2026-07-13 13:16:45.691+02	\N
01KXDKCFEAQ4K747A0942ZJ06S	01KSCSTSP7N25SPSF2H5AK45FY	vendor	new_message	Nouveau message		{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSRC31WGAE8QWZC9PM6RMS3Y"}	f	2026-07-13 13:21:49.258+02	2026-07-13 13:21:49.258+02	\N
01KZSMC1NDH3DSN2T7Q7ZJWHVF	cus_01KZSMC1GNSS9SXPZ2ZX39N7J9	customer	reward_won	You won a reward!	You won 5% off on the daily wheel — code EM-M1ERBFUG.	{"label": "5% off", "coupon_id": "01KZSMC1N6Z0HXKWTY4TY0BRW8", "coupon_code": "EM-M1ERBFUG", "customer_id": "cus_01KZSMC1GNSS9SXPZ2ZX39N7J9"}	f	2026-08-12 02:01:20.557+02	2026-08-12 02:01:20.557+02	\N
01KZSMEY5ZJTG78EGQ485A2YSN	cus_01KZSMEY0DNJ1VVM2P3S3T3222	customer	reward_won	You won a reward!	You won 10% off on the daily wheel — code EM-O9X2TFZJ.	{"label": "10% off", "coupon_id": "01KZSMEY5NZBK8RPPP0B5EH6XZ", "coupon_code": "EM-O9X2TFZJ", "customer_id": "cus_01KZSMEY0DNJ1VVM2P3S3T3222"}	f	2026-08-12 02:02:55.295+02	2026-08-12 02:02:55.295+02	\N
01KZSRKTBPES7QWV1FS2S9343H	cus_01KZSRK3GY7H9W4XQEVRX7V4ZX	customer	new_order	Commande confirmée	Votre commande #16 a été confirmée.	{"order_id": "order_01KZSRKT0QNS81MFMA4G05RZ8E", "display_id": 16}	f	2026-08-12 03:15:29.527+02	2026-08-12 03:15:29.527+02	\N
01KZSRKTBXTHJ882QA5676R9ZY	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_order	Nouvelle commande	Vous avez reçu une nouvelle commande #16.	{"order_id": "order_01KZSRKT0QNS81MFMA4G05RZ8E", "display_id": 16}	f	2026-08-12 03:15:29.534+02	2026-08-12 03:15:29.534+02	\N
01KZSRPH45BK6M2NT9CFRBZHZH	cus_01KZSRPF04TZB7SAT86MV8YP2J	customer	new_order	Commande confirmée	Votre commande #17 a été confirmée.	{"order_id": "order_01KZSRPGT61RWGZEV4XWSST4DB", "display_id": 17}	f	2026-08-12 03:16:58.373+02	2026-08-12 03:16:58.373+02	\N
01KZSRPH4A0EMP3VN66MD59S8E	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_order	Nouvelle commande	Vous avez reçu une nouvelle commande #17.	{"order_id": "order_01KZSRPGT61RWGZEV4XWSST4DB", "display_id": 17}	f	2026-08-12 03:16:58.378+02	2026-08-12 03:16:58.378+02	\N
01KZSRT9EA1K0DS31H4NJQPQMH	cus_01KZSRT7Q29W9N12GXQK6SVY8E	customer	new_order	Commande confirmée	Votre commande #18 a été confirmée.	{"order_id": "order_01KZSRT94K7A6N76KXHBVTJKMJ", "display_id": 18}	f	2026-08-12 03:19:01.578+02	2026-08-12 03:19:01.578+02	\N
01KZSRT9EG0HBWJBFX858W5JY5	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_order	Nouvelle commande	Vous avez reçu une nouvelle commande #18.	{"order_id": "order_01KZSRT94K7A6N76KXHBVTJKMJ", "display_id": 18}	f	2026-08-12 03:19:01.584+02	2026-08-12 03:19:01.584+02	\N
01KZSS4E9WAGXER7DJJKZDPKY1	cus_01KZSS4CJSGT6HDXZ310W1C82K	customer	new_order	Commande confirmée	Votre commande #19 a été confirmée.	{"order_id": "order_01KZSS4E0E2TDSQ1CZW34GVH80", "display_id": 19}	f	2026-08-12 03:24:34.236+02	2026-08-12 03:24:34.236+02	\N
01KZSS4EA065F6CKH8NT3VEM10	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_order	Nouvelle commande	Vous avez reçu une nouvelle commande #19.	{"order_id": "order_01KZSS4E0E2TDSQ1CZW34GVH80", "display_id": 19}	f	2026-08-12 03:24:34.241+02	2026-08-12 03:24:34.241+02	\N
01KZSS71DDBBDGFCMR0EWMJ875	cus_01KZSS6ZQW5RQBDPWQCEDQ0BVR	customer	new_order	Commande confirmée	Votre commande #20 a été confirmée.	{"order_id": "order_01KZSS713JEJG13A30NW7X2RR7", "display_id": 20}	f	2026-08-12 03:25:59.341+02	2026-08-12 03:25:59.341+02	\N
01KZSS71DJDFR2527KECGG84WC	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_order	Nouvelle commande	Vous avez reçu une nouvelle commande #20.	{"order_id": "order_01KZSS713JEJG13A30NW7X2RR7", "display_id": 20}	f	2026-08-12 03:25:59.346+02	2026-08-12 03:25:59.347+02	\N
01KZTFBR58YXYXKW4T35SKV6AB	cus_01KZTFASX63451FWPYQZST4A8M	customer	new_order	Commande confirmée	Votre commande #21 a été confirmée.	{"order_id": "order_01KZTFBQSNE8M83ECV3F4F3K9J", "display_id": 21}	f	2026-08-12 09:53:02.376+02	2026-08-12 09:53:02.376+02	\N
01KZTFBR62NNRNG90PW1HGZZTP	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_order	Nouvelle commande	Vous avez reçu une nouvelle commande #21.	{"order_id": "order_01KZTFBQSNE8M83ECV3F4F3K9J", "display_id": 21}	f	2026-08-12 09:53:02.403+02	2026-08-12 09:53:02.403+02	\N
01KZTFBR7RWF06MD4SH1ARQM6B	cus_01KZSMAT6WFYWBGMFDGBSQVMKG	customer	referral_reward	Your referral just made a purchase!	You earned a 10% off coupon — code EM-DV0ZJ3KZ.	{"coupon_code": "EM-DV0ZJ3KZ"}	f	2026-08-12 09:53:02.456+02	2026-08-12 09:53:02.456+02	\N
01KZTFBR7S4KHGH4EGQ9XSMG4R	cus_01KZTFASX63451FWPYQZST4A8M	customer	referral_reward	Welcome bonus unlocked!	Thanks for your first order — here's a 10% off coupon, code EM-XRE56ZBF.	{"coupon_code": "EM-XRE56ZBF"}	f	2026-08-12 09:53:02.457+02	2026-08-12 09:53:02.457+02	\N
01KZYENPT04XGQE3B1NM7DJM7J	01KV5CHYWYZVSNYGB0RXEYG5CK	vendor	new_message	Nouveau message	Bonjour\n\n📦 Sandale - 300 EUR	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KVAQ8F8QB8M9CP6908W8S37S"}	f	2026-08-13 22:57:57.825+02	2026-08-13 22:57:57.825+02	\N
01KZYEPWAWW6R2AEF4QQSAT7V5	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	reward_won	You won a reward!	You won Free shipping on the daily wheel — code EM-NMNFJW5W.	{"label": "Free shipping", "coupon_id": "01KZYEPWAC5PZFXTEJ5HJSDJXS", "coupon_code": "EM-NMNFJW5W", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8"}	f	2026-08-13 22:58:36.252+02	2026-08-13 22:58:36.252+02	\N
01KZYGJ7B5R82D748YR9PHGVEM	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Bonjour	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-08-13 23:31:00.837+02	2026-08-13 23:31:00.837+02	\N
01KZYGKK6NGW9ZBQDE2ZMS6YB3	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	🎤 Message vocal	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-08-13 23:31:45.75+02	2026-08-13 23:31:45.75+02	\N
01KZYK0GKFJXJCD7NT74YPCCAE	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	🎤 Message vocal	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-08-14 00:13:46.223+02	2026-08-14 00:13:46.223+02	\N
01KZYK6NC5DWW02T1ANPX846V9	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Hello	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-08-14 00:17:07.717+02	2026-08-14 00:17:07.717+02	\N
01M015G9QR3557B0F61C7PZ6N9	01KV5CHYWYZVSNYGB0RXEYG5CK	vendor	new_message	Message de prince lulindagg	💰 Offre : 30 USD pour Sandales plates pour femmes  (Modèles assortis)	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KVAQ8F8QB8M9CP6908W8S37S"}	f	2026-08-15 00:15:26.712+02	2026-08-15 00:15:26.712+02	\N
01M02AMP3H4PC0490DZA380QZV	01KV5CHYWYZVSNYGB0RXEYG5CK	vendor	new_message	Message de prince lulindagg	🎤 Message vocal	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KVAQ8F8QB8M9CP6908W8S37S"}	f	2026-08-15 11:04:27.761+02	2026-08-15 11:04:27.761+02	\N
01M02AP05RVE25DY4THWDN406J	01KV5CHYWYZVSNYGB0RXEYG5CK	vendor	new_message	Message de prince lulindagg	🎤 Message vocal	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KVAQ8F8QB8M9CP6908W8S37S"}	f	2026-08-15 11:05:10.841+02	2026-08-15 11:05:10.841+02	\N
01M02B05RWDZ2FEAYJGZW4ED63	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Message de prince lulindagg	🎤 Message vocal	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-08-15 11:10:44.252+02	2026-08-15 11:10:44.252+02	\N
01M02B169VZTGFXGDBASSA9YW6	01KSCSTSP7N25SPSF2H5AK45FY	vendor	new_message	Message de prince lulindagg	🎤 Message vocal	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSRC31WGAE8QWZC9PM6RMS3Y"}	f	2026-08-15 11:11:17.563+02	2026-08-15 11:11:17.563+02	\N
01M02B66ZJEJPDPRF9N0GQC5KM	01KV5CHYWYZVSNYGB0RXEYG5CK	vendor	new_message	Message de prince lulindagg	bonjour!	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KVAQ8F8QB8M9CP6908W8S37S"}	f	2026-08-15 11:14:02.098+02	2026-08-15 11:14:02.098+02	\N
01M02B731FVWY4ZHK2HH8JEXTB	01KV5CHYWYZVSNYGB0RXEYG5CK	vendor	new_message	Message de prince lulindagg	Réactions et menu d'actions\n\nNouveau composant partagé components/chat/MessageActions.tsx :\n- Messag	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KVAQ8F8QB8M9CP6908W8S37S"}	f	2026-08-15 11:14:30.831+02	2026-08-15 11:14:30.831+02	\N
01M02CE5CVFZPJ50NBSN0TEW2M	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Message de prince lulindagg	bonjour	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-08-15 11:35:51.195+02	2026-08-15 11:35:51.195+02	\N
01M02CGQWF0ZK3X368WN8WPZMA	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Message de prince lulindagg	voici la video	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-08-15 11:37:15.664+02	2026-08-15 11:37:15.664+02	\N
01M02CM1CY6N2RC1T5QQDM8M7S	01KV5CHYWYZVSNYGB0RXEYG5CK	vendor	new_message	Message de prince lulindagg	jj	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KVAQ8F8QB8M9CP6908W8S37S"}	f	2026-08-15 11:39:03.711+02	2026-08-15 11:39:03.711+02	\N
01M02CMSEKGHZ47EV66YJD357Z	01KV5CHYWYZVSNYGB0RXEYG5CK	vendor	new_message	Message de prince lulindagg	hello	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KVAQ8F8QB8M9CP6908W8S37S"}	f	2026-08-15 11:39:28.34+02	2026-08-15 11:39:28.34+02	\N
01M014ZZWMQX6GPFCM6MB2HNNS	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	cart_reminder	Votre panier vous attend 🛒	Une question avant de commander ? Posez-la directement au vendeur dans le chat.	{"screen": "/cart-page"}	t	2026-08-15 00:06:32.34+02	2026-08-15 21:20:21.063+02	\N
\.


--
-- Data for Name: application_method_buy_rules; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.application_method_buy_rules (application_method_id, promotion_rule_id) FROM stdin;
\.


--
-- Data for Name: application_method_target_rules; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.application_method_target_rules (application_method_id, promotion_rule_id) FROM stdin;
proappmet_01KZSNVQVJBD4J6NZG0BF7QE85	prorul_01KZSNVQVMT8DYTTNA50SF2Z98
proappmet_01KZV29F65P9N6CBXA7VTMH2GE	prorul_01KZV29F68FNS6X4JF1VRBFTSK
\.


--
-- Data for Name: auth_identity; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.auth_identity (id, app_metadata, created_at, updated_at, deleted_at) FROM stdin;
authid_01KSCRW56M4HHGZ62YKHD3GN8G	{"user_id": "user_01KSCRW542GHYQFHM9FB3QZM2J"}	2026-05-24 12:35:44.213+02	2026-05-24 12:35:44.219+02	\N
authid_01KZSMBZR902D3F11JK6AJFYQG	{"customer_id": "cus_01KZSMBZSJPHZ5M70N0KP35E5G"}	2026-08-12 02:01:18.601+02	2026-08-12 02:01:18.645+02	\N
authid_01KSDGJHCTKACVMAMDBVGKA4AN	{"customer_id": "cus_01KSDGQE4N7DEJ0C3Q810Y8CYP"}	2026-05-24 19:29:54.843+02	2026-05-24 19:32:35.364+02	\N
authid_01KSQWK78GPYSWFDV5PD3K0GNQ	{"customer_id": "cus_01KSQWM10KJ2G0R75KZJYHDB6H"}	2026-05-28 20:12:24.464+02	2026-05-28 20:12:50.844+02	\N
authid_01KSR173CHW8REA4FMY690R5MR	{"customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8"}	2026-05-28 21:33:10.161+02	2026-05-28 21:33:10.23+02	\N
authid_01KSVPWAJ6G79SQV5S2Q26FGGG	{"customer_id": "cus_01KSVPWBFY9T5MZXK47CYD788Q"}	2026-05-30 07:49:29.03+02	2026-05-30 07:49:30.002+02	\N
authid_01KSWS7TY7W4PDKT3K7A9ZPYCK	{"customer_id": "cus_01KSWS7V39C4SDB1YTY9K83SMS"}	2026-05-30 17:49:57.831+02	2026-05-30 17:49:58.009+02	\N
authid_01KV52QSB6KCFEFGP4DHVBFPN3	\N	2026-06-15 09:25:34.951+02	2026-06-15 09:25:34.951+02	\N
authid_01KZSMC003CJY6E6J67H3RCNKB	{"customer_id": "cus_01KZSMC01DK743K662A96FWK8D"}	2026-08-12 02:01:18.851+02	2026-08-12 02:01:18.897+02	\N
authid_01KZSMC07VVSNVQ5EZD4S78F07	{"customer_id": "cus_01KZSMC096Y09WY697T3056N0G"}	2026-08-12 02:01:19.099+02	2026-08-12 02:01:19.146+02	\N
authid_01KV54R4B6M7GYEJ4GXWR3GEKC	{"vendor_id": "01KV54RE4N8QPSN5CHZ9SZYNWC"}	2026-06-15 10:00:43.367+02	2026-06-15 10:00:53.417+02	\N
authid_01KSCS5ZMFWQ794DK9P2KTPC9H	{"vendor_id": "01KSCS6FHM3T088JTDVNHWEAP0"}	2026-05-24 12:41:06.192+02	2026-05-24 12:41:22.494+02	\N
authid_01KSCSTEDYTSQVWN8D97W0H5S6	{"vendor_id": "01KSCSTSPDSEAN744XV198F4RD"}	2026-05-24 12:52:16.702+02	2026-05-24 12:52:28.244+02	\N
authid_01KSDE84ASAVWY2BJH057MCBXY	{"vendor_id": "01KSDE9JW0MFK1W1NWQ29QV25V"}	2026-05-24 18:49:16.633+02	2026-05-24 18:50:04.293+02	\N
authid_01KV56RDJXKE7M18TXCTM63A6C	\N	2026-06-15 10:35:49.982+02	2026-06-15 10:35:49.982+02	\N
authid_01KV56WXHNWPD4FJBPCKR4FXV1	{"vendor_id": "01KV57JBZJBSBM5WA0NG4M45HR"}	2026-06-15 10:38:17.397+02	2026-06-15 10:50:00.314+02	\N
authid_01KV5AFEKE05VZFMD54HZWC5W3	\N	2026-06-15 11:40:50.414+02	2026-06-15 11:40:50.414+02	\N
authid_01KV5BJNV0G2JVFH7Y3HSQAKPY	{"vendor_id": "01KV5BKD1EKP3MQ5XSTZXDK22X"}	2026-06-15 12:00:04.704+02	2026-06-15 12:00:28.469+02	\N
authid_01KV5BN08HFC5239YBN9SM3X6Q	{"vendor_id": "01KV5BPJD5F7AVY4D00DCTWX6G"}	2026-06-15 12:01:20.913+02	2026-06-15 12:02:12.268+02	\N
authid_01KV5CHGRSJN97BQ66DS6X142Y	{"vendor_id": "01KV5CHYXFFSYJHQ816P112AMS"}	2026-06-15 12:16:55.321+02	2026-06-15 12:17:09.82+02	\N
authid_01KV65ZRR29AGAN8CME1Y0DTA8	{"vendor_id": "01KV660ATYEE23FKSY15PCJAAF"}	2026-06-15 19:41:36.643+02	2026-06-15 19:41:55.179+02	\N
authid_01KV69XRE72ETY0V232QHGV6J5	{"vendor_id": "01KV69YB4B12G19BWNKS8TEGA2"}	2026-06-15 20:50:25.095+02	2026-06-15 20:50:44.242+02	\N
authid_01KWSMFX3T0E0MNAD50BQA1CVG	{"vendor_id": "01KWSMG9MVNFPCA37HG7TJ35KN"}	2026-07-05 19:16:21.499+02	2026-07-05 19:16:34.347+02	\N
authid_01KTEM0BVY5132SFAV1H149V4W	{"customer": "cus_01KVDNF9NVQVFFF9WFB56HN13V"}	2026-06-06 16:04:49.918+02	2026-07-06 03:42:52.86+02	\N
authid_01KWTFT49FQHKSA1NCZVMEZS8V	{"customer": "cus_01KWTHT7FNHAP08HMCSJ9NW4P9"}	2026-07-06 03:13:48.08+02	2026-07-06 03:48:48.518+02	\N
authid_01KWTJAF0VVSBSVA4RCTCVVW0N	{"customer_id": "cus_01KWTJAF28STSEK2811R1QW1ZW"}	2026-07-06 03:57:40.508+02	2026-07-06 03:57:40.563+02	\N
authid_01KWTJDTP09MK80G456S7SBPGN	{"customer_id": "cus_01KWTJDVCJA6KHS6TX3DTG1P1K"}	2026-07-06 03:59:30.752+02	2026-07-06 03:59:31.486+02	\N
authid_01KWWN41SH31MN1VSFE540JFHJ	\N	2026-07-06 23:25:04.945+02	2026-07-06 23:25:04.945+02	\N
authid_01KWXQ71CQP932KYCYRTG2TP6S	{"customer": "cus_01KWXQ71ESXH4GETPYWRYMRFJK"}	2026-07-07 09:20:54.425+02	2026-07-07 09:20:54.547+02	\N
authid_01KWXQCXQJS4MSHHMYVZWBDM0M	{"customer": "cus_01KWXQCXR7D8SR1DYEGETXBERC"}	2026-07-07 09:24:07.282+02	2026-07-07 09:24:07.313+02	\N
authid_01KXDCKEV31BJHP4RYPND0BMZA	{"customer": "cus_01KWTHT7FNHAP08HMCSJ9NW4P9"}	2026-07-13 11:23:17.987+02	2026-07-13 11:23:18.014+02	\N
authid_01KZSMAT59RX6KP1X9JBZ8MXTA	{"customer_id": "cus_01KZSMAT6WFYWBGMFDGBSQVMKG"}	2026-08-12 02:00:40.105+02	2026-08-12 02:00:40.161+02	\N
authid_01KZSMBZ800M84CNVTNCJTPFEZ	{"customer_id": "cus_01KZSMBZ99Z0Q8P5KTCWCBMJ73"}	2026-08-12 02:01:18.08+02	2026-08-12 02:01:18.127+02	\N
authid_01KZSMBZG5VSWYB00W8KA340AE	{"customer_id": "cus_01KZSMBZHQEP9A4XJX4MPZBXC4"}	2026-08-12 02:01:18.341+02	2026-08-12 02:01:18.395+02	\N
authid_01KZSMC0FN3S22P81BEG93PM48	{"customer_id": "cus_01KZSMC0H1D16FKPAF1RH2CT27"}	2026-08-12 02:01:19.349+02	2026-08-12 02:01:19.397+02	\N
authid_01KZSMC0QYQKZJNVX9MS5PAFF9	{"customer_id": "cus_01KZSMC0SBE2M7VR1R9XBKMQFY"}	2026-08-12 02:01:19.614+02	2026-08-12 02:01:19.665+02	\N
authid_01KZSMC103P379067ZJXGHEFJC	{"customer_id": "cus_01KZSMC11E5Y9F9SDEM99VXJPS"}	2026-08-12 02:01:19.876+02	2026-08-12 02:01:19.924+02	\N
authid_01KZSMC17VE6WHD0X05Z7ZP2RG	{"customer_id": "cus_01KZSMC195G8H5AHKKYE09VZX2"}	2026-08-12 02:01:20.123+02	2026-08-12 02:01:20.168+02	\N
authid_01KZSMC1FB5A60SDVC425YMAN2	{"customer_id": "cus_01KZSMC1GNSS9SXPZ2ZX39N7J9"}	2026-08-12 02:01:20.363+02	2026-08-12 02:01:20.408+02	\N
authid_01KZSMC1QQTP5HPGAPTPNXW26Q	{"customer_id": "cus_01KZSMC1S8PAS0DKWVYD1TNNPM"}	2026-08-12 02:01:20.631+02	2026-08-12 02:01:20.691+02	\N
authid_01KZSMC211K3EXD6KV663KG1ZQ	{"customer_id": "cus_01KZSMC22GW2AVN7D38GNN414A"}	2026-08-12 02:01:20.929+02	2026-08-12 02:01:20.979+02	\N
authid_01KZSMEXM49GBRBN29F44ACZ7T	{"customer_id": "cus_01KZSMEXNKDNW2N4PS3SQCG84M"}	2026-08-12 02:02:54.725+02	2026-08-12 02:02:54.781+02	\N
authid_01KZSMEXYJ5AVJYN48N086SVX8	{"customer_id": "cus_01KZSMEY0DNJ1VVM2P3S3T3222"}	2026-08-12 02:02:55.058+02	2026-08-12 02:02:55.124+02	\N
authid_01KZSNDA7RBN8RA48W9WCD9NQM	\N	2026-08-12 02:19:30.68+02	2026-08-12 02:19:30.68+02	\N
authid_01KZSNE0M36DT75HAQQ1XYT0EW	{"vendor_id": "01KZSNE0NACP4N12MCZ8A4CFC1"}	2026-08-12 02:19:53.604+02	2026-08-12 02:19:53.653+02	\N
authid_01KZTETPYDM6S7FMMNGQXTVHKF	{"customer_id": "cus_01KZTETSA89TK03RE3G06BXQDJ"}	2026-08-12 09:43:44.078+02	2026-08-12 09:43:46.53+02	\N
authid_01KZTFASSQPBTYBMRHAT7S1ZXA	{"customer_id": "cus_01KZTFASX63451FWPYQZST4A8M"}	2026-08-12 09:52:31.288+02	2026-08-12 09:52:31.421+02	\N
authid_01KZV2PT8Q3Z6BXEN6ZJ7BYRP8	{"customer_id": "cus_01KZV2PTYGTZ4E2VCQ7R28NYVF"}	2026-08-12 15:31:07.927+02	2026-08-12 15:31:08.641+02	\N
authid_01M0196VW9Q4ZQ0VCQXACR0D9X	{"customer_id": "cus_01M0196WGTMRHZWT20K8ZDQ9ZF"}	2026-08-15 01:20:11.913+02	2026-08-15 01:20:12.581+02	\N
authid_01M019BF4JJPDQYTEAPNRZERWG	{"customer_id": "cus_01M019BGZDAKS45SQB3VRG2PW5"}	2026-08-15 01:22:42.706+02	2026-08-15 01:22:44.617+02	\N
authid_01M019M0VFMVS74E77G4ZE2M1C	{"customer_id": "cus_01M019M1H41EYR3ETMFFPDJNQA"}	2026-08-15 01:27:22.992+02	2026-08-15 01:27:23.694+02	\N
authid_01M01ABZ24PD8R0B2FAEMNDSJ4	{"customer_id": "cus_01M01ABZNY6SPV79YG95TRCN89"}	2026-08-15 01:40:27.588+02	2026-08-15 01:40:28.237+02	\N
authid_01M01C3VXW1VNAPWJ1AFTXP1KM	{"customer_id": "cus_01M01C3WQD8YCZYFB1B6QQE5AE"}	2026-08-15 02:10:59.389+02	2026-08-15 02:11:00.228+02	\N
authid_01M01CP98CWR4XWQKK2TAKGBBM	\N	2026-08-15 02:21:02.861+02	2026-08-15 02:21:02.861+02	\N
authid_01M01D4F8GDRKJKR2RN4REZ7R1	{"customer_id": "cus_01M01D4FZGTRMJ99SJJ3WWS4B8"}	2026-08-15 02:28:47.76+02	2026-08-15 02:28:48.521+02	\N
\.


--
-- Data for Name: capture; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.capture (id, amount, raw_amount, payment_id, created_at, updated_at, deleted_at, created_by, metadata) FROM stdin;
capt_01KSWZH7X99HJ1W6FV6MSAQTJS	10100	{"value": "10100", "precision": 20}	pay_01KSWZ94X29003ZASHHKTR2F82	2026-05-30 19:39:57.481+02	2026-05-30 19:39:57.481+02	\N	\N	\N
\.


--
-- Data for Name: cart; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart (id, region_id, customer_id, sales_channel_id, email, currency_code, shipping_address_id, billing_address_id, metadata, created_at, updated_at, deleted_at, completed_at, locale) FROM stdin;
cart_01KSDGR3DAN1CC1QCD9SK3RTYQ	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	cus_01KSDGQE4N7DEJ0C3Q810Y8CYP	sc_01KSCR9E3HDNX82KGM4FXZDGP1	princelulinda78@gmail.com	usd	caaddr_01KSR0SKAVA44DY9Y2WDGB14CD	\N	\N	2026-05-24 19:32:57.133+02	2026-05-28 21:25:47.74+02	\N	\N	\N
cart_01KSWSK33QH11CN1HH7SCYTME0	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	cus_01KSWS7V39C4SDB1YTY9K83SMS	sc_01KSCR9E3HDNX82KGM4FXZDGP1	princelulinda11@gmail.com	usd	\N	\N	\N	2026-05-30 17:56:06.647+02	2026-05-30 17:56:06.647+02	\N	\N	\N
cart_01KSR17JJKRN19AW6DGG1ZNZXC	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	cus_01KSR173ECD4A2AJF6H3R1H2J8	sc_01KSCR9E3HDNX82KGM4FXZDGP1	princelulinda10@gmail.com	usd	caaddr_01KSWZ8TYYCAF6QP9560EZTTJG	\N	\N	2026-05-28 21:33:25.716+02	2026-05-30 19:35:32.228+02	\N	2026-05-30 19:35:32.17+02	\N
cart_01KSYNPXZ7GKJRHYWE8HXZQPEJ	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	cus_01KSR173ECD4A2AJF6H3R1H2J8	sc_01KSCR9E3HDNX82KGM4FXZDGP1	princelulinda32@gmail.com	usd	caaddr_01KSYNQE7K9XVQWTKQEFSNPJPC	\N	\N	2026-05-31 11:26:47.016+02	2026-05-31 11:27:25.461+02	\N	2026-05-31 11:27:25.45+02	\N
cart_01KSYPV5SG04S1KMPP10R93K65	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	cus_01KSR173ECD4A2AJF6H3R1H2J8	sc_01KSCR9E3HDNX82KGM4FXZDGP1	princelulinda32@gmail.com	usd	caaddr_01KSYPVEKBXJE2SEW1G4P59BJ9	\N	\N	2026-05-31 11:46:34.673+02	2026-05-31 11:47:04.391+02	\N	2026-05-31 11:47:04.373+02	\N
cart_01KSYRTG3P2TYAY5NJK34GCSQC	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	cus_01KSR173ECD4A2AJF6H3R1H2J8	sc_01KSCR9E3HDNX82KGM4FXZDGP1	princelulinda32@gmail.com	usd	caaddr_01KSYZ4QME861R0G40764HRC9S	\N	\N	2026-05-31 12:21:09.623+02	2026-05-31 14:11:47.39+02	\N	2026-05-31 14:11:47.377+02	\N
cart_01KSYZ93PAWAQ3YMSX95CPEDAW	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	cus_01KSR173ECD4A2AJF6H3R1H2J8	sc_01KSCR9E3HDNX82KGM4FXZDGP1	princelulinda32@gmail.com	usd	caaddr_01KSYZ9C59RTEKYFNV9N24AT3E	\N	\N	2026-05-31 14:13:59.883+02	2026-05-31 14:14:18.265+02	\N	2026-05-31 14:14:18.254+02	\N
cart_01KSYZD7RA6NWZ1QPAGBP73146	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	cus_01KSR173ECD4A2AJF6H3R1H2J8	sc_01KSCR9E3HDNX82KGM4FXZDGP1	princelulinda32@gmail.com	usd	caaddr_01KSYZDXBNBKTS04MFD7HB4EPC	\N	\N	2026-05-31 14:16:15.115+02	2026-05-31 14:16:57.755+02	\N	2026-05-31 14:16:57.74+02	\N
cart_01KSZ01P234X82AKV9N28KZVJA	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	cus_01KSR173ECD4A2AJF6H3R1H2J8	sc_01KSCR9E3HDNX82KGM4FXZDGP1	princelulinda32@gmail.com	usd	caaddr_01KSZ01Y1WMSTH1M1SCX7BZH5S	\N	\N	2026-05-31 14:27:25.124+02	2026-05-31 14:27:40.83+02	\N	2026-05-31 14:27:40.814+02	\N
cart_01KSZ03JDPKWSSPAQ2AB3D3A5B	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	cus_01KSR173ECD4A2AJF6H3R1H2J8	sc_01KSCR9E3HDNX82KGM4FXZDGP1	princelulinda32@gmail.com	usd	caaddr_01KSZ03SW4ME6JQAHTCFHFH0BD	\N	\N	2026-05-31 14:28:26.935+02	2026-05-31 14:28:41.637+02	\N	2026-05-31 14:28:41.614+02	\N
cart_01KSZ0TTA6QMT1NTEB871F845G	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	cus_01KSR173ECD4A2AJF6H3R1H2J8	sc_01KSCR9E3HDNX82KGM4FXZDGP1	princelulinda32@gmail.com	usd	caaddr_01KSZ0V2HYR2KBM79AQS8VGVXB	\N	\N	2026-05-31 14:41:08.68+02	2026-05-31 14:41:25.84+02	\N	2026-05-31 14:41:25.825+02	\N
cart_01KT1VZFSW5FDQCERA8BX242EF	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	cus_01KSR173ECD4A2AJF6H3R1H2J8	sc_01KSCR9E3HDNX82KGM4FXZDGP1	princelulinda32@gmail.com	usd	caaddr_01KTED28JT6ENF4FQPJ666VGWY	\N	\N	2026-06-01 17:14:02.176+02	2026-06-06 14:03:32.059+02	\N	\N	\N
cart_01KVDDT6Q0N62W5SA9JZJK6E9B	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	sc_01KSCR9E3HDNX82KGM4FXZDGP1	\N	usd	\N	\N	\N	2026-06-18 15:13:03.969+02	2026-06-18 15:13:03.969+02	\N	\N	\N
cart_01KVDKH2HKR1RF5YJFXH1AQP8S	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	cus_01KVDNF9NVQVFFF9WFB56HN13V	sc_01KSCR9E3HDNX82KGM4FXZDGP1	princelulinda@gmail.com	usd	caaddr_01KVEXKRAPVAS34D96T3WY3ME1	\N	\N	2026-06-18 16:52:56.244+02	2026-06-19 05:08:24.279+02	\N	\N	\N
cart_01KVF21BZHAQPMVMPMJFST02K8	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	cus_01KSR173ECD4A2AJF6H3R1H2J8	sc_01KSCR9E3HDNX82KGM4FXZDGP1	princelulinda32@gmail.com	usd	caaddr_01KW3GEW27XEGT5Z3YQSXY8HED	\N	\N	2026-06-19 06:25:44.692+02	2026-06-27 05:02:35.849+02	\N	\N	\N
cart_01KWD9APC4K8KKYZMVC3DT1YDJ	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	cus_01KSR173ECD4A2AJF6H3R1H2J8	sc_01KSCR9E3HDNX82KGM4FXZDGP1	princelulinda32@gmail.com	usd	\N	\N	\N	2026-07-01 00:10:23.238+02	2026-07-01 00:10:23.238+02	\N	\N	\N
cart_01KWT6EQA1B67FMAWJ43XXT9MW	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	sc_01KSCR9E3HDNX82KGM4FXZDGP1	\N	usd	\N	\N	\N	2026-07-06 00:30:17.155+02	2026-07-06 00:30:17.155+02	\N	\N	\N
cart_01KWXQH6P0G9QEZJTNMVNJQNEP	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	sc_01KSCR9E3HDNX82KGM4FXZDGP1	\N	usd	\N	\N	\N	2026-07-07 09:26:27.521+02	2026-07-07 09:26:27.521+02	\N	\N	\N
cart_01KZSMCSWP4QVQTSGSDR52CJND	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	sc_01KSCR9E3HDNX82KGM4FXZDGP1	\N	usd	\N	\N	\N	2026-08-12 02:01:45.367+02	2026-08-12 02:01:45.367+02	\N	\N	\N
cart_01KZSMFE2TR1GA2RG73BGXCMD9	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	sc_01KSCR9E3HDNX82KGM4FXZDGP1	\N	usd	\N	\N	\N	2026-08-12 02:03:11.579+02	2026-08-12 02:03:11.579+02	\N	\N	\N
cart_01KZSNW83S6222HZ28KHMG9EXJ	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	cus_01KZSRK3GY7H9W4XQEVRX7V4ZX	sc_01KSCR9E3HDNX82KGM4FXZDGP1	socialprooftest@example.com	usd	caaddr_01KZSRK3HTNGZQJYCMZPYFADTY	\N	\N	2026-08-12 02:27:40.028+02	2026-08-12 03:15:29.309+02	\N	2026-08-12 03:15:29.254+02	\N
cart_01KZSRP068BQQP8TQNEB823ZCV	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	cus_01KZSRPF04TZB7SAT86MV8YP2J	sc_01KSCR9E3HDNX82KGM4FXZDGP1	socialprooftest2@example.com	usd	caaddr_01KZSRPF1576X3V36HBESKY3CH	\N	\N	2026-08-12 03:16:41.035+02	2026-08-12 03:16:58.179+02	\N	2026-08-12 03:16:58.124+02	\N
cart_01KZSRT71KMHMWX9DFAXP33T7W	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	cus_01KZSRT7Q29W9N12GXQK6SVY8E	sc_01KSCR9E3HDNX82KGM4FXZDGP1	debugtest@example.com	usd	caaddr_01KZSRT7QVKNH6QYSKHWM2K67G	\N	\N	2026-08-12 03:18:59.127+02	2026-08-12 03:19:01.367+02	\N	2026-08-12 03:19:01.33+02	\N
cart_01KZSS4BKPNCHBFWMGN0624ZPN	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	cus_01KZSS4CJSGT6HDXZ310W1C82K	sc_01KSCR9E3HDNX82KGM4FXZDGP1	debugtest3@example.com	usd	caaddr_01KZSS4CKK4CVHEJAF1Z79WF69	\N	\N	2026-08-12 03:24:31.482+02	2026-08-12 03:24:34.048+02	\N	2026-08-12 03:24:34.005+02	\N
cart_01KZSS6Z30MMS0FNSH6K4H7HKY	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	cus_01KZSS6ZQW5RQBDPWQCEDQ0BVR	sc_01KSCR9E3HDNX82KGM4FXZDGP1	debugtest4@example.com	usd	caaddr_01KZSS6ZRMSEZ3T6W2KQ8WR4JS	\N	\N	2026-08-12 03:25:56.963+02	2026-08-12 03:25:59.13+02	\N	2026-08-12 03:25:59.093+02	\N
cart_01KZTFBNRPB6DYYAKDVDE4TQPB	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	cus_01KZTFASX63451FWPYQZST4A8M	sc_01KSCR9E3HDNX82KGM4FXZDGP1	referredbuyer@example.com	usd	caaddr_01KZTFBPDXG8GRDC3PC2WQWF9T	\N	\N	2026-08-12 09:52:59.928+02	2026-08-12 09:53:02.12+02	\N	2026-08-12 09:53:02.077+02	\N
cart_01KVAGCKDTWERGJ7WG6JW897EZ	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	cus_01KSR173ECD4A2AJF6H3R1H2J8	sc_01KSCR9E3HDNX82KGM4FXZDGP1	princelulinda32@gmail.com	usd	caaddr_01KZYEY0XJK53SG8MN30V38J7F	\N	\N	2026-06-17 12:00:20.667+02	2026-08-13 23:02:30.323+02	\N	\N	\N
cart_01KXDHGKG57TMWKDAB6RT07J3C	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	cus_01KSR173ECD4A2AJF6H3R1H2J8	sc_01KSCR9E3HDNX82KGM4FXZDGP1	princelulinda32@gmail.com	usd	caaddr_01M035GS5PFJ46SN4E45Y9XR2E	\N	\N	2026-07-13 12:49:07.335+02	2026-08-15 18:54:11.39+02	\N	\N	\N
cart_01M03BTH03XPFMS67EZH32CE0N	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	cus_01KSR173ECD4A2AJF6H3R1H2J8	sc_01KSCR9E3HDNX82KGM4FXZDGP1	princelulinda32@gmail.com	usd	\N	\N	\N	2026-08-15 20:44:22.148+02	2026-08-15 20:44:22.148+02	\N	\N	\N
\.


--
-- Data for Name: cart_address; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart_address (id, customer_id, company, first_name, last_name, address_1, address_2, city, country_code, province, postal_code, phone, metadata, created_at, updated_at, deleted_at) FROM stdin;
caaddr_01KSR0SKAVA44DY9Y2WDGB14CD	\N	\N	Prince	lulinda	Line	Gifugwe	Gifurwe	bi	\N			\N	2026-05-28 21:25:47.739+02	2026-05-28 21:25:47.739+02	\N
caaddr_01KSR1BYWEK77NBCB9GG9FWCRW	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-28 21:35:49.391+02	2026-05-28 21:35:49.391+02	\N
caaddr_01KSR1ZYEEWBQRR7ZT0XJK5069	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-28 21:46:44.302+02	2026-05-28 21:46:44.302+02	\N
caaddr_01KSR1ZYSMDTQACAMRS8TNJNG0	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-28 21:46:44.66+02	2026-05-28 21:46:44.66+02	\N
caaddr_01KSR246K6KRXJ6V0FG8B9NK23	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-28 21:49:03.718+02	2026-05-28 21:49:03.718+02	\N
caaddr_01KSR2515T0GP7D4XM91Z3K3XD	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-28 21:49:30.938+02	2026-05-28 21:49:30.938+02	\N
caaddr_01KSR2NZ6M8VHCYMDDM7X1FG8K	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-28 21:58:45.972+02	2026-05-28 21:58:45.972+02	\N
caaddr_01KSR2QJBR9NN2FK4W7R5YHA6V	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-28 21:59:38.36+02	2026-05-28 21:59:38.36+02	\N
caaddr_01KSR2ZV09N6P0SBKBM94ERRGC	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-28 22:04:09.353+02	2026-05-28 22:04:09.353+02	\N
caaddr_01KSSDEAA2GXFV9G3993F75487	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-29 10:26:03.971+02	2026-05-29 10:26:03.971+02	\N
caaddr_01KSVPXRF1CDFJ5YRTRYF4VPXF	\N	\N	prince	-	Line 1		Musenyi	bi	\N			\N	2026-05-30 07:50:16.034+02	2026-05-30 07:50:16.034+02	\N
caaddr_01KSW49EDD10D8BE3BC9GZ4C6S	\N	\N	prince	-	Line 1		Musenyi	bi	\N			\N	2026-05-30 11:43:50.445+02	2026-05-30 11:43:50.445+02	\N
caaddr_01KSWJH12F9YY33G0J1YKRD0RS	\N	\N	prince	-	Line 1		Musenyi	bi	\N			\N	2026-05-30 15:52:38.992+02	2026-05-30 15:52:38.992+02	\N
caaddr_01KSWJM17PS51XEHAS9E5X867D	\N	\N	prince	-	Line 1		Musenyi	bi	\N			\N	2026-05-30 15:54:17.463+02	2026-05-30 15:54:17.463+02	\N
caaddr_01KSWJX1FZ143RBQD7EZ7Z3M37	\N	\N	prince	-	Line 1		Musenyi	bi	\N			\N	2026-05-30 15:59:12.639+02	2026-05-30 15:59:12.639+02	\N
caaddr_01KSWJYX2J6T1ZXVQNGHZ2W7EC	\N	\N	prince	-	Line 1		Musenyi	bi	\N			\N	2026-05-30 16:00:13.651+02	2026-05-30 16:00:13.651+02	\N
caaddr_01KSWK0VG72K3GD7V6328T1CEX	\N	\N	prince	-	Line 1		Musenyi	bi	\N			\N	2026-05-30 16:01:17.576+02	2026-05-30 16:01:17.576+02	\N
caaddr_01KSWK0WJ667ZS0MTZZ3K3KBYQ	\N	\N	prince	-	Line 1		Musenyi	bi	\N			\N	2026-05-30 16:01:18.662+02	2026-05-30 16:01:18.662+02	\N
caaddr_01KSWN6GN0V7712Q5HJDR6S6JF	\N	\N	prince	-	Line 1		Musenyi	bi	\N			\N	2026-05-30 16:39:20.225+02	2026-05-30 16:39:20.225+02	\N
caaddr_01KSWN93BRPJB3T0NYJV5T88W9	\N	\N	prince	-	Line 1		Musenyi	bi	\N			\N	2026-05-30 16:40:44.921+02	2026-05-30 16:40:44.921+02	\N
caaddr_01KSWNANTS1YXT3H86PDZVMQC7	\N	\N	prince	-	Line 1		Musenyi	bi	\N			\N	2026-05-30 16:41:36.601+02	2026-05-30 16:41:36.601+02	\N
caaddr_01KSWNGVSZTK85Z77JRJW09F61	\N	\N	prince	-	Line 1		Musenyi	bi	\N			\N	2026-05-30 16:44:59.327+02	2026-05-30 16:44:59.327+02	\N
caaddr_01KSWNM8ATKWW94NJM9HTH6S31	\N	\N	prince	-	Line 1		Musenyi	bi	\N			\N	2026-05-30 16:46:50.459+02	2026-05-30 16:46:50.459+02	\N
caaddr_01KSWZ8TYYCAF6QP9560EZTTJG	\N	\N	prince	-	Line 1		Musenyi	bi	\N			\N	2026-05-30 19:35:22.079+02	2026-05-30 19:35:22.079+02	\N
caaddr_01KSYNQE7K9XVQWTKQEFSNPJPC	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-31 11:27:03.667+02	2026-05-31 11:27:03.667+02	\N
caaddr_01KSYPVEKBXJE2SEW1G4P59BJ9	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-31 11:46:43.692+02	2026-05-31 11:46:43.692+02	\N
caaddr_01KSYZ4QME861R0G40764HRC9S	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-31 14:11:36.462+02	2026-05-31 14:11:36.462+02	\N
caaddr_01KSYZ9C59RTEKYFNV9N24AT3E	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-31 14:14:08.553+02	2026-05-31 14:14:08.553+02	\N
caaddr_01KSYZDXBNBKTS04MFD7HB4EPC	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-31 14:16:37.238+02	2026-05-31 14:16:37.238+02	\N
caaddr_01KSZ01Y1WMSTH1M1SCX7BZH5S	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-31 14:27:33.309+02	2026-05-31 14:27:33.309+02	\N
caaddr_01KSZ03SW4ME6JQAHTCFHFH0BD	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-31 14:28:34.564+02	2026-05-31 14:28:34.564+02	\N
caaddr_01KSZ0V2HYR2KBM79AQS8VGVXB	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-31 14:41:17.118+02	2026-05-31 14:41:17.118+02	\N
caaddr_01KT1W1MEM88NBVG4STQ952AYJ	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-01 17:15:12.468+02	2026-06-01 17:15:12.468+02	\N
caaddr_01KT1Y3TM4HFRRT6QW86JPSGSG	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-01 17:51:21.476+02	2026-06-01 17:51:21.476+02	\N
caaddr_01KT1YXZN1Q4A2R944Y0JZXWEA	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-01 18:05:38.594+02	2026-06-01 18:05:38.594+02	\N
caaddr_01KT1YZPVNPTBKX1MHER1R2XDS	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-01 18:06:35.125+02	2026-06-01 18:06:35.125+02	\N
caaddr_01KT1Z2S5KH653HEW96V63FRBJ	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-01 18:08:15.795+02	2026-06-01 18:08:15.795+02	\N
caaddr_01KT1ZJCEY2CCDQVF05DB180N2	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-01 18:16:47.071+02	2026-06-01 18:16:47.071+02	\N
caaddr_01KT1ZN85EHFHY8Q73TQEA9XA9	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-01 18:18:20.974+02	2026-06-01 18:18:20.974+02	\N
caaddr_01KT1ZPGW306ZZJ1CBX9TN4CEW	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-01 18:19:02.659+02	2026-06-01 18:19:02.659+02	\N
caaddr_01KT1ZRPZAM1BCZQG54SN33BVZ	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-01 18:20:14.442+02	2026-06-01 18:20:14.442+02	\N
caaddr_01KT1ZTDM4WKFHGRF17FFYT5EW	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-01 18:21:10.405+02	2026-06-01 18:21:10.405+02	\N
caaddr_01KT208MKDB30JBAX0TWR7W0DJ	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-01 18:28:56.302+02	2026-06-01 18:28:56.302+02	\N
caaddr_01KT6JC4XHG885XN6C2MA4PASK	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-03 13:02:23.409+02	2026-06-03 13:02:23.409+02	\N
caaddr_01KT6K25B5GKMVXQN6YVCMWAPP	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-03 13:14:24.742+02	2026-06-03 13:14:24.742+02	\N
caaddr_01KT6N3GQK27JFCJ43AC1B7M74	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-03 13:50:06.323+02	2026-06-03 13:50:06.323+02	\N
caaddr_01KT6SSDGZ2AN38P2N0R5VPE7Z	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-03 15:11:58.24+02	2026-06-03 15:11:58.24+02	\N
caaddr_01KT6W10V44GMY9HD5FGTRJFM2	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-03 15:51:04.549+02	2026-06-03 15:51:04.549+02	\N
caaddr_01KT6ZN22CGPJ420YSV1HNNYDC	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-03 16:54:26.893+02	2026-06-03 16:54:26.893+02	\N
caaddr_01KT77Y7TKG6WEMEB7X7GPNVP3	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-03 19:19:16.307+02	2026-06-03 19:19:16.307+02	\N
caaddr_01KT7AD7RQQV6E7D5HX7MZPGZE	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-03 20:02:24.919+02	2026-06-03 20:02:24.919+02	\N
caaddr_01KT8YR21W35MV7481RST8BW62	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 11:17:05.469+02	2026-06-04 11:17:05.469+02	\N
caaddr_01KT942D4MPT80V67V3EN5WQT4	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 12:50:07.38+02	2026-06-04 12:50:07.38+02	\N
caaddr_01KT949W51C93PQYCTWC2N2QSP	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 12:54:12.129+02	2026-06-04 12:54:12.129+02	\N
caaddr_01KT94ENW6EYFMW5JNDRDYRB45	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 12:56:49.543+02	2026-06-04 12:56:49.543+02	\N
caaddr_01KT95RBYC6KPCKJ53VP81R80Q	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 13:19:35.629+02	2026-06-04 13:19:35.629+02	\N
caaddr_01KT9647Z2TM6BBG5CKM5QBW0N	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 13:26:04.771+02	2026-06-04 13:26:04.771+02	\N
caaddr_01KT97725JBS2EY4J4ERY3SS6X	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 13:45:05.714+02	2026-06-04 13:45:05.714+02	\N
caaddr_01KT97ZJY8SBJX9HJQJS5YWP9P	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 13:58:29.321+02	2026-06-04 13:58:29.321+02	\N
caaddr_01KT984XTBF9G7RZH8SGATBWZG	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 14:01:24.3+02	2026-06-04 14:01:24.3+02	\N
caaddr_01KT98JNZ5AS062JN779DD85V5	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 14:08:55.013+02	2026-06-04 14:08:55.013+02	\N
caaddr_01KT9944GFBGAD150W66JN0PFP	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 14:18:26.96+02	2026-06-04 14:18:26.96+02	\N
caaddr_01KT99DZQYM7HVN2N5JJZ1FRT3	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 14:23:49.759+02	2026-06-04 14:23:49.759+02	\N
caaddr_01KT99FHD2DXG12AQZ2MZXAJRA	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 14:24:40.61+02	2026-06-04 14:24:40.61+02	\N
caaddr_01KT99KHFV3R1A7FTK699JWTF4	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 14:26:51.771+02	2026-06-04 14:26:51.771+02	\N
caaddr_01KT9ABMFJRXN2BTC9WZH49SX0	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 14:40:01.266+02	2026-06-04 14:40:01.266+02	\N
caaddr_01KT9AHKB2FH7K7M0EM9CHBB76	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 14:43:16.706+02	2026-06-04 14:43:16.706+02	\N
caaddr_01KT9BJ02654RABNM3V326PFP8	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 15:00:58.31+02	2026-06-04 15:00:58.31+02	\N
caaddr_01KT9C64R2AKGQXCWDNB75MWMS	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 15:11:58.467+02	2026-06-04 15:11:58.467+02	\N
caaddr_01KT9D0H69J9R616VW8PSC9RKG	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 15:26:23.178+02	2026-06-04 15:26:23.178+02	\N
caaddr_01KT9V3GCWWKW71WKPAM8E8ESH	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 19:32:40.732+02	2026-06-04 19:32:40.732+02	\N
caaddr_01KT9VFERZRHFA1J8H5N5270BJ	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 19:39:12.288+02	2026-06-04 19:39:12.288+02	\N
caaddr_01KTA1R977XCCXNDPFB1TB4REC	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 21:28:52.968+02	2026-06-04 21:28:52.968+02	\N
caaddr_01KTA2E7YM7J4YXF194ENWQP5C	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 21:40:52.564+02	2026-06-04 21:40:52.564+02	\N
caaddr_01KTA2J52VAVYSPJ1BN76AT0DY	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 21:43:00.699+02	2026-06-04 21:43:00.699+02	\N
caaddr_01KTA3CFEFAPCERXNFNV5NXXJM	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 21:57:23.28+02	2026-06-04 21:57:23.28+02	\N
caaddr_01KTA3GJ7BV2CTJ1NRS70TZ3RB	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 21:59:37.195+02	2026-06-04 21:59:37.195+02	\N
caaddr_01KTA7WDJD9BMHWQTWZNDV32Q4	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 23:15:59.949+02	2026-06-04 23:15:59.949+02	\N
caaddr_01KTA7XEEN61QZQJBGXG1C67XS	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 23:16:33.621+02	2026-06-04 23:16:33.621+02	\N
caaddr_01KTA7XERFPJER7F6007P2YFN9	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 23:16:33.935+02	2026-06-04 23:16:33.935+02	\N
caaddr_01KTA7XSE5Y9Z34QEBMDQAXG7Z	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 23:16:44.869+02	2026-06-04 23:16:44.869+02	\N
caaddr_01KTA92JCF5T9ST0Y2TNRKE5QD	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 23:36:50.063+02	2026-06-04 23:36:50.063+02	\N
caaddr_01KTA9803Z765P192BR5W7VXX2	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 23:39:47.968+02	2026-06-04 23:39:47.968+02	\N
caaddr_01KTA9H4YCYTPN817KJB8BGGHE	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-04 23:44:47.82+02	2026-06-04 23:44:47.82+02	\N
caaddr_01KTAAVK6VDA7RNE8ZB2VTBSYJ	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 00:07:58.683+02	2026-06-05 00:07:58.683+02	\N
caaddr_01KTAB8S02QP5H2K7Z44VZFCN8	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 00:15:10.594+02	2026-06-05 00:15:10.595+02	\N
caaddr_01KTABB7FDQ17J1Q89K8Y1FNB5	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 00:16:30.957+02	2026-06-05 00:16:30.957+02	\N
caaddr_01KTABBEJQ4V8AF0APET19F8KF	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 00:16:38.231+02	2026-06-05 00:16:38.231+02	\N
caaddr_01KTABCFNQZPM1S9C3Y2D31C75	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 00:17:12.119+02	2026-06-05 00:17:12.119+02	\N
caaddr_01KTABYK4TJKHA2XX4W8AJXTXJ	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 00:27:05.499+02	2026-06-05 00:27:05.499+02	\N
caaddr_01KTABZWNMYXBEM2H56ANHBFCQ	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 00:27:48.021+02	2026-06-05 00:27:48.021+02	\N
caaddr_01KTAC00YABRQ04RS1RFSMVCBB	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 00:27:52.395+02	2026-06-05 00:27:52.395+02	\N
caaddr_01KTAC089CHQQ9XNABN6W9THHP	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 00:27:59.917+02	2026-06-05 00:27:59.917+02	\N
caaddr_01KTAC6QWX327P6RNHN6MW2BS1	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 00:31:32.509+02	2026-06-05 00:31:32.509+02	\N
caaddr_01KTAC7YW0VRYCEVW5VWQ36T5H	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 00:32:12.416+02	2026-06-05 00:32:12.416+02	\N
caaddr_01KTACB52FPBGW97233G5AJ83K	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 00:33:57.072+02	2026-06-05 00:33:57.072+02	\N
caaddr_01KTACFZH6SWSEJMN64QTXBFA8	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 00:36:35.238+02	2026-06-05 00:36:35.238+02	\N
caaddr_01KTACM21E3GQ2C6PSMQF3YKX2	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 00:38:48.879+02	2026-06-05 00:38:48.879+02	\N
caaddr_01KTACNYA9F34B06XRN1R39762	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 00:39:50.602+02	2026-06-05 00:39:50.602+02	\N
caaddr_01KTAD1N6WQVQ9162FJZ1K2J6E	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 00:46:14.493+02	2026-06-05 00:46:14.493+02	\N
caaddr_01KTADDS96QXA9653RZGDHT7Z6	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 00:52:51.878+02	2026-06-05 00:52:51.878+02	\N
caaddr_01KTADFGRAY79HE9NN6G34JADY	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 00:53:48.683+02	2026-06-05 00:53:48.683+02	\N
caaddr_01KTADGAP8P13BRF0KPX545372	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 00:54:15.24+02	2026-06-05 00:54:15.24+02	\N
caaddr_01KTAEEV4SYDEQ8SCNFRWZSH89	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 01:10:55.13+02	2026-06-05 01:10:55.13+02	\N
caaddr_01KTAES6FJ0ZV2DDJC30W51214	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 01:16:34.419+02	2026-06-05 01:16:34.419+02	\N
caaddr_01KTAEWB5NVJ9B60E5TVPSF1EQ	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 01:18:17.525+02	2026-06-05 01:18:17.525+02	\N
caaddr_01KTAF13SSSXVATA6GQ7GD8BMB	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 01:20:53.817+02	2026-06-05 01:20:53.817+02	\N
caaddr_01KTAF2ZA8V9NS99NX09AE0AXG	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 01:21:54.761+02	2026-06-05 01:21:54.761+02	\N
caaddr_01KTAF6ZW1W6T4AVX7VZKNTCSP	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 01:24:06.401+02	2026-06-05 01:24:06.401+02	\N
caaddr_01KTAFDQENQ9Y23EWG66VMYXCK	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 01:27:47.157+02	2026-06-05 01:27:47.157+02	\N
caaddr_01KTAFPW0PYDVYQDXJA0FTMSBK	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 01:32:46.742+02	2026-06-05 01:32:46.742+02	\N
caaddr_01KTBBG1RRHRQYYGTST12AAM8X	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 09:38:23.384+02	2026-06-05 09:38:23.384+02	\N
caaddr_01KTBBYW92BTS15H6DDQ5070XW	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 09:46:29.283+02	2026-06-05 09:46:29.283+02	\N
caaddr_01KTBC90NH6RDMBQJ7Q2TYVW40	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 09:52:01.457+02	2026-06-05 09:52:01.458+02	\N
caaddr_01KTBCE38CYHMKERNA2A0DCCTN	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 09:54:47.948+02	2026-06-05 09:54:47.948+02	\N
caaddr_01KTBDA4AZCHWQM0AC905KGABV	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 10:10:06.56+02	2026-06-05 10:10:06.56+02	\N
caaddr_01KTBDSCF0ZVZ5768AMFRCNGWJ	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 10:18:26.4+02	2026-06-05 10:18:26.4+02	\N
caaddr_01KTBDWS8FTWJDHT73F06569WH	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 10:20:17.808+02	2026-06-05 10:20:17.808+02	\N
caaddr_01KTBE5HX1044S93SADXZGAH8M	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 10:25:05.185+02	2026-06-05 10:25:05.185+02	\N
caaddr_01KTBE9TP29YDC5XS55VC6JDRC	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 10:27:25.25+02	2026-06-05 10:27:25.25+02	\N
caaddr_01KTCFNKF5Z9EGRBNNQDG94DZ0	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 20:10:34.086+02	2026-06-05 20:10:34.086+02	\N
caaddr_01KTCHRSEC0PD3FS3FS68S27YR	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 20:47:15.66+02	2026-06-05 20:47:15.66+02	\N
caaddr_01KTCHWYFDWYAYZ98G9587W442	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 20:49:31.885+02	2026-06-05 20:49:31.885+02	\N
caaddr_01KTCJ6GHT02GGN9AKNT2EFHKT	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 20:54:45.306+02	2026-06-05 20:54:45.306+02	\N
caaddr_01KTCJ7W2FYDES8PJHDZTJ565C	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-05 20:55:29.871+02	2026-06-05 20:55:29.872+02	\N
caaddr_01KTE608CHKAJZ2Z774X56Q1RV	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-06 12:00:06.289+02	2026-06-06 12:00:06.289+02	\N
caaddr_01KTE67MNMD928X7Q98PEHCCS5	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-06 12:04:08.244+02	2026-06-06 12:04:08.244+02	\N
caaddr_01KTEC8B7QZKFX0H8AKP3S09NZ	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-06 13:49:22.807+02	2026-06-06 13:49:22.807+02	\N
caaddr_01KTECH2RM2H026QWKQ8CZ9Z4T	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-06 13:54:09.044+02	2026-06-06 13:54:09.044+02	\N
caaddr_01KTED28JT6ENF4FQPJ666VGWY	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-06 14:03:32.059+02	2026-06-06 14:03:32.059+02	\N
caaddr_01KVATND0RS82PSWC17ZJ1WSJF	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-17 14:59:54.776+02	2026-06-17 14:59:54.776+02	\N
caaddr_01KVAXBFJ6XSJH2XT644FQYBB5	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-17 15:46:55.43+02	2026-06-17 15:46:55.43+02	\N
caaddr_01KVAXSD7XYZEEDBAHB3X8Y9AH	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-17 15:54:31.806+02	2026-06-17 15:54:31.806+02	\N
caaddr_01KVAY1AEZ7WDJHVQ17500VMYH	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-17 15:58:51.104+02	2026-06-17 15:58:51.104+02	\N
caaddr_01KVAYWXEMEXGAW19H7WEAGSWM	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-17 16:13:55.285+02	2026-06-17 16:13:55.285+02	\N
caaddr_01KVB5YSPD3TGC7CBF7CS9KSHV	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-17 18:17:17.005+02	2026-06-17 18:17:17.005+02	\N
caaddr_01KVB6KZ70BGZE5MSERZ01YSSC	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-17 18:28:50.785+02	2026-06-17 18:28:50.785+02	\N
caaddr_01KVB75AST7NMKSJXY1CSWRH0N	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-17 18:38:19.707+02	2026-06-17 18:38:19.707+02	\N
caaddr_01KVB7E15QXGSTNA868CP1T8K2	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-17 18:43:04.759+02	2026-06-17 18:43:04.759+02	\N
caaddr_01KVCTC4V0PH7924XF94VAZGYB	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-06-18 09:33:20.352+02	2026-06-18 09:33:20.352+02	\N
caaddr_01KVDNF9P1DCVZF78MECEBR6MV	\N	\N	Prince	Crespo	Kamenge	\N	Bujumbura	bi	\N	212	+25767881752	\N	2026-06-18 17:26:55.17+02	2026-06-18 17:26:55.17+02	\N
caaddr_01KVDNWFKST384N51NN0AX2Z87	\N	\N	Prince	Crespo	Kamenge	\N	Bujumbura	bi	\N	212	+25767881752	\N	2026-06-18 17:34:07.225+02	2026-06-18 17:34:07.225+02	\N
caaddr_01KVDPDMVX491WW35B99PJNPA3	\N	\N	Prince	Crespo	Kamenge	\N	Bujumbura	bi	\N	221	+25767881752	\N	2026-06-18 17:43:29.661+02	2026-06-18 17:43:29.661+02	\N
caaddr_01KVEXKRAPVAS34D96T3WY3ME1	\N	\N	Prince	Crespo	Kamenge	\N	Bujumbura	bi	\N	555	+25767881752	\N	2026-06-19 05:08:24.278+02	2026-06-19 05:08:24.278+02	\N
caaddr_01KVF22B1ZC48XKRABA70ZT322	\N	\N	Prince	lulinda	Kamenge	\N	Bujumbura	bi	\N	555	+25767881752	\N	2026-06-19 06:26:16.512+02	2026-06-19 06:26:16.512+02	\N
caaddr_01KW3GEW27XEGT5Z3YQSXY8HED	\N	\N	prince	lulinda	Kamenge	\N	Bujumbura	bi	\N	555	+25767881752	\N	2026-06-27 05:02:35.848+02	2026-06-27 05:02:35.848+02	\N
caaddr_01KXDHMQSG14Z5GBGBDYW7NK2P	\N	\N	Prince	Crespo	Kamenge	\N	Bujumbura	bi	\N	555	67881752	\N	2026-07-13 12:51:22.801+02	2026-07-13 12:51:22.801+02	\N
caaddr_01KXDPZJHXH40MHKY02WMVE0CE	\N	\N	Prince	Crespo	Kamenge	\N	Bujumbura	bi	\N	9767	67881752	\N	2026-07-13 14:24:40.765+02	2026-07-13 14:24:40.765+02	\N
caaddr_01KXG92NYVWP40TJJ0ZZSRW4WT	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-07-14 14:19:25.787+02	2026-07-14 14:19:25.787+02	\N
caaddr_01KXG988D0HHEHGQT3WZHEKQQW	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-07-14 14:22:28.512+02	2026-07-14 14:22:28.512+02	\N
caaddr_01KXG989W5B5D4MT8470CFH49A	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-07-14 14:22:30.021+02	2026-07-14 14:22:30.021+02	\N
caaddr_01KZSRK3HTNGZQJYCMZPYFADTY	\N	\N	Social	Proof	1 Test St	\N	Testville	cg	\N	00000	+33600000000	\N	2026-08-12 03:15:06.171+02	2026-08-12 03:15:06.171+02	\N
caaddr_01KZSRPF1576X3V36HBESKY3CH	\N	\N	Social	Proof2	1 Test St	\N	Testville	cg	\N	00000	+33600000000	\N	2026-08-12 03:16:56.23+02	2026-08-12 03:16:56.23+02	\N
caaddr_01KZSRT7QVKNH6QYSKHWM2K67G	\N	\N	Debug	Test	1 Test St	\N	Testville	cg	\N	00000	+33600000000	\N	2026-08-12 03:18:59.836+02	2026-08-12 03:18:59.836+02	\N
caaddr_01KZSS4CKK4CVHEJAF1Z79WF69	\N	\N	Debug	Three	1 Test St	\N	Testville	cg	\N	00000	+33600000000	\N	2026-08-12 03:24:32.499+02	2026-08-12 03:24:32.499+02	\N
caaddr_01KZSS6ZRMSEZ3T6W2KQ8WR4JS	\N	\N	Debug	Four	1 Test St	\N	Testville	cg	\N	00000	+33600000000	\N	2026-08-12 03:25:57.653+02	2026-08-12 03:25:57.653+02	\N
caaddr_01KZTFBPDXG8GRDC3PC2WQWF9T	\N	\N	Referred	Buyer	1 Test St	\N	Testville	cg	\N	00000	+33600000000	\N	2026-08-12 09:53:00.605+02	2026-08-12 09:53:00.605+02	\N
caaddr_01KZV5X70D4745QV5NE66YCJEZ	\N	\N	Prince	lulinda	Bujumbura	Gifugwe	Gifurwe	bi	\N		667881752	\N	2026-08-12 16:27:03.309+02	2026-08-12 16:27:03.309+02	\N
caaddr_01KZYEQV9YTPAKVXRW928EQFP5	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-08-13 22:59:07.967+02	2026-08-13 22:59:07.967+02	\N
caaddr_01KZYEY0XJK53SG8MN30V38J7F	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-08-13 23:02:30.323+02	2026-08-13 23:02:30.323+02	\N
caaddr_01M035GS5PFJ46SN4E45Y9XR2E	\N	\N	prince	lulindagg	Kamenge	\N	Bujumbura	bi	\N	555	67881752	\N	2026-08-15 18:54:11.386+02	2026-08-15 18:54:11.386+02	\N
\.


--
-- Data for Name: cart_line_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart_line_item (id, cart_id, title, subtitle, thumbnail, quantity, variant_id, product_id, product_title, product_description, product_subtitle, product_type, product_collection, product_handle, variant_sku, variant_barcode, variant_title, variant_option_values, requires_shipping, is_discountable, is_tax_inclusive, compare_at_unit_price, raw_compare_at_unit_price, unit_price, raw_unit_price, metadata, created_at, updated_at, deleted_at, product_type_id, is_custom_price, is_giftcard) FROM stdin;
cali_01KSQXG576W8DQSNRHQD008HVJ	cart_01KSDGR3DAN1CC1QCD9SK3RTYQ	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	1	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-05-28 20:28:12.646+02	2026-05-28 20:28:12.646+02	\N	\N	f	f
cali_01KSR17KC9GSV21GKBCMGNSN9K	cart_01KSR17JJKRN19AW6DGG1ZNZXC	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	1	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-05-28 21:33:26.537+02	2026-05-28 21:59:16.614+02	2026-05-28 21:59:16.613+02	\N	f	f
cali_01KSZ01PT04V18KYBH0AX6ZWKV	cart_01KSZ01P234X82AKV9N28KZVJA	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	1	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-05-31 14:27:25.888+02	2026-05-31 14:27:25.888+02	\N	\N	f	f
cali_01KSR2QAZ0T745YZGWQ6MNWXN8	cart_01KSR17JJKRN19AW6DGG1ZNZXC	Medusa Sweatpants	XL	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatpants-gray-front.png	1	variant_01KSCR9EBC6292NXWNKFT12BMR	prod_01KSCR9EA81H268P4TP8HZKH76	Medusa Sweatpants	Reimagine the feeling of classic sweatpants. With our cotton sweatpants, everyday essentials no longer have to be ordinary.	\N	\N	\N	sweatpants	SWEATPANTS-XL	\N	XL	\N	t	t	f	\N	\N	15	{"value": "15", "precision": 20}	{}	2026-05-28 21:59:30.784+02	2026-05-29 13:06:05.997+02	2026-05-29 13:06:05.996+02	\N	f	f
cali_01KSSPNCZ95QMPJZAEKX9NFBK3	cart_01KSR17JJKRN19AW6DGG1ZNZXC	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	1	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-05-29 13:07:13.257+02	2026-05-30 07:41:50.431+02	2026-05-30 07:41:50.429+02	\N	f	f
cali_01KSVPFZN2G6AATK2DYJQZDGGM	cart_01KSR17JJKRN19AW6DGG1ZNZXC	Medusa T-Shirt	XL / Black	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-front.png	1	variant_01KSCR9EBC5APY2TXMQGMBGJJR	prod_01KSCR9EA8QJ19M3XNSJCQTBKP	Medusa T-Shirt	Reimagine the feeling of a classic T-shirt. With our cotton T-shirts, everyday essentials no longer have to be ordinary.	\N	\N	\N	t-shirt	SHIRT-XL-BLACK	\N	XL / Black	\N	t	t	f	\N	\N	15	{"value": "15", "precision": 20}	{}	2026-05-30 07:42:44.642+02	2026-05-30 16:39:14.327+02	2026-05-30 16:39:14.325+02	\N	f	f
cali_01KSVPFHY08813JTTEV5JEMDWQ	cart_01KSR17JJKRN19AW6DGG1ZNZXC	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	1	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-05-30 07:42:30.593+02	2026-05-30 16:39:31.264+02	2026-05-30 16:39:31.264+02	\N	f	f
cali_01KSWN8RF0H83RXJ2H6PPJQAB4	cart_01KSR17JJKRN19AW6DGG1ZNZXC	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	1	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-05-30 16:40:33.76+02	2026-05-30 16:40:33.76+02	\N	\N	f	f
cali_01KSWSK639BJJVEYE86SDMBG15	cart_01KSWSK33QH11CN1HH7SCYTME0	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	1	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-05-30 17:56:09.706+02	2026-05-30 17:56:09.706+02	\N	\N	f	f
cali_01KSYNPYTHG371AN0YR69M3HJC	cart_01KSYNPXZ7GKJRHYWE8HXZQPEJ	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	1	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-05-31 11:26:47.889+02	2026-05-31 11:26:47.889+02	\N	\N	f	f
cali_01KSYPV6ZS2VJ4VXXXW5CGFVBF	cart_01KSYPV5SG04S1KMPP10R93K65	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	3	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-05-31 11:46:35.897+02	2026-05-31 11:46:35.897+02	\N	\N	f	f
cali_01KSYZ4H6V2HHDDJDJ9WXY2FT2	cart_01KSYRTG3P2TYAY5NJK34GCSQC	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	1	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-05-31 14:11:29.883+02	2026-05-31 14:11:29.883+02	\N	\N	f	f
cali_01KSYZ95ARS2X2454BMFECRC99	cart_01KSYZ93PAWAQ3YMSX95CPEDAW	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	1	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-05-31 14:14:01.56+02	2026-05-31 14:14:01.56+02	\N	\N	f	f
cali_01KSYZDAFZTS2R8YPVQR752Y9W	cart_01KSYZD7RA6NWZ1QPAGBP73146	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	2	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-05-31 14:16:17.92+02	2026-05-31 14:16:17.92+02	\N	\N	f	f
cali_01KSZ03K8ZZDGMZCP93REA2K4J	cart_01KSZ03JDPKWSSPAQ2AB3D3A5B	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	1	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-05-31 14:28:27.807+02	2026-05-31 14:28:27.807+02	\N	\N	f	f
cali_01KSZ0TV3CEGGPTTHYXXK1F08E	cart_01KSZ0TTA6QMT1NTEB871F845G	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	1	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-05-31 14:41:09.485+02	2026-05-31 14:41:09.485+02	\N	\N	f	f
cali_01KT1W1AXX60G9869ZZ1Q9Y9T3	cart_01KT1VZFSW5FDQCERA8BX242EF	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	1	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-06-01 17:15:02.718+02	2026-06-04 12:55:23.41+02	2026-06-04 12:55:23.409+02	\N	f	f
cali_01KT94DPGS5FPKHABVGXG2FE32	cart_01KT1VZFSW5FDQCERA8BX242EF	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	1	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-06-04 12:56:17.434+02	2026-06-04 23:17:09.725+02	2026-06-04 23:17:09.724+02	\N	f	f
cali_01KTA7Z2PX415ZRJRPT2NWMFDT	cart_01KT1VZFSW5FDQCERA8BX242EF	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	2	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-06-04 23:17:27.133+02	2026-06-06 14:32:02.831+02	\N	\N	f	f
cali_01KVAGCMSGGZ1ECN8HQQV2HRX4	cart_01KVAGCKDTWERGJ7WG6JW897EZ	Gg	Vert	https://s3.eastmarket.africa/eastmarket/image-01KV5JR733EB6YJ4A4G4TNYWNN.jpg	1	variant_01KV5K1Y7Y8GVH4HFJ28G7C2ST	prod_01KV5K1Y66BRSD3K4GDMN4M1YS	Gg	\N	\N	\N	\N	gg	\N	\N	Vert	\N	t	t	f	\N	\N	1000	{"value": "1000", "precision": 20}	{}	2026-06-17 12:00:22.064+02	2026-06-17 15:46:11.505+02	2026-06-17 15:46:11.505+02	\N	f	f
cali_01KVAKR8FEGETND0A999V3R4NT	cart_01KVAGCKDTWERGJ7WG6JW897EZ	Sandales plates pour femmes  (Modèles assortis)	36 / Rouge	https://s3.eastmarket.africa/eastmarket/image-01KVAGYGR5HSSKB5HN5VY7MM8M.jpg	1	variant_01KVAHVT2EBVYQBAVTR9ZSV73R	prod_01KVAHVT1115P37Z781SCQWX1W	Sandales plates pour femmes  (Modèles assortis)	Sandales plates confortables pour femmes, disponibles en plusieurs modèles et coloris élégants (marron, beige, noir, bordeaux). Idéales pour le quotidien.	\N	\N	\N	sandales-plates-pour-femmes-modeles-assortis	\N	\N	36 / Rouge	\N	t	t	f	\N	\N	200	{"value": "200", "precision": 20}	{}	2026-06-17 12:59:08.398+02	2026-06-17 15:45:48.74+02	2026-06-17 15:45:48.737+02	\N	f	f
cali_01KVAJ5M8KV0VXC8ER9EBX4G0K	cart_01KVAGCKDTWERGJ7WG6JW897EZ	Sandales plates pour femmes  (Modèles assortis)	36 / Noir	https://s3.eastmarket.africa/eastmarket/image-01KVAGYGR5HSSKB5HN5VY7MM8M.jpg	3	variant_01KVAHVT2EKW039PVGG0YMCKJ1	prod_01KVAHVT1115P37Z781SCQWX1W	Sandales plates pour femmes  (Modèles assortis)	Sandales plates confortables pour femmes, disponibles en plusieurs modèles et coloris élégants (marron, beige, noir, bordeaux). Idéales pour le quotidien.	\N	\N	\N	sandales-plates-pour-femmes-modeles-assortis	\N	\N	36 / Noir	\N	t	t	f	\N	\N	200	{"value": "200", "precision": 20}	{}	2026-06-17 12:31:29.299+02	2026-06-17 15:46:13.001+02	2026-06-17 15:46:13+02	\N	f	f
cali_01KVDF34GG1W1GMN059HD6X8G9	cart_01KVDDT6Q0N62W5SA9JZJK6E9B	Gg	Noire	https://s3.eastmarket.africa/eastmarket/image-01KV5JR733EB6YJ4A4G4TNYWNN.jpg	10	variant_01KV5K1Y7ZB131EVPGZ9M407MM	prod_01KV5K1Y66BRSD3K4GDMN4M1YS	Gg	\N	\N	\N	\N	gg	BBBB	\N	Noire	\N	t	t	f	\N	\N	1900	{"value": "1900", "precision": 20}	{}	2026-06-18 15:35:25.201+02	2026-06-18 15:35:25.201+02	\N	\N	f	f
cali_01KVDKHPRCRTX9PW119V13VP4Q	cart_01KVDKH2HKR1RF5YJFXH1AQP8S	Gg	Vert	https://s3.eastmarket.africa/eastmarket/image-01KV5JR733EB6YJ4A4G4TNYWNN.jpg	10	variant_01KV5K1Y7Y8GVH4HFJ28G7C2ST	prod_01KV5K1Y66BRSD3K4GDMN4M1YS	Gg	\N	\N	\N	\N	gg	\N	\N	Vert	\N	t	t	f	\N	\N	1000	{"value": "1000", "precision": 20}	{}	2026-06-18 16:53:16.94+02	2026-06-19 05:52:31.821+02	2026-06-19 05:52:31.818+02	\N	f	f
cali_01KVDKHJNHETA050TB2KN8D1X0	cart_01KVDKH2HKR1RF5YJFXH1AQP8S	Gg	Rouge	https://s3.eastmarket.africa/eastmarket/image-01KV5JR733EB6YJ4A4G4TNYWNN.jpg	10	variant_01KV5K1Y7YYFQVWGAWEBNRGXB9	prod_01KV5K1Y66BRSD3K4GDMN4M1YS	Gg	\N	\N	\N	\N	gg	\N	\N	Rouge	\N	t	t	f	\N	\N	1000	{"value": "1000", "precision": 20}	{}	2026-06-18 16:53:12.753+02	2026-06-19 05:52:37.75+02	2026-06-19 05:52:37.749+02	\N	f	f
cali_01KVDKHDTFX8VN81TR8SY3CMZV	cart_01KVDKH2HKR1RF5YJFXH1AQP8S	Gg	Noire	https://s3.eastmarket.africa/eastmarket/image-01KV5JR733EB6YJ4A4G4TNYWNN.jpg	10	variant_01KV5K1Y7ZB131EVPGZ9M407MM	prod_01KV5K1Y66BRSD3K4GDMN4M1YS	Gg	\N	\N	\N	\N	gg	BBBB	\N	Noire	\N	t	t	f	\N	\N	1900	{"value": "1900", "precision": 20}	{}	2026-06-18 16:53:07.791+02	2026-06-19 05:55:32.196+02	2026-06-19 05:55:32.195+02	\N	f	f
cali_01KVF21CC8C6F2MK6JMW6MWZPC	cart_01KVF21BZHAQPMVMPMJFST02K8	Gg	Noire	https://s3.eastmarket.africa/eastmarket/image-01KV5JR733EB6YJ4A4G4TNYWNN.jpg	10	variant_01KV5K1Y7ZB131EVPGZ9M407MM	prod_01KV5K1Y66BRSD3K4GDMN4M1YS	Gg	\N	\N	\N	\N	gg	BBBB	\N	Noire	\N	t	t	f	\N	\N	1900	{"value": "1900", "precision": 20}	{}	2026-06-19 06:25:45.097+02	2026-06-30 15:46:21.456+02	2026-06-30 15:46:21.454+02	\N	f	f
cali_01KWH9GV7AMBJ6WD1B3TV0B3BW	cart_01KWD9APC4K8KKYZMVC3DT1YDJ	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	1	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-07-02 13:30:42.539+02	2026-07-02 17:04:47.848+02	2026-07-02 17:04:47.843+02	\N	f	f
cali_01KWD8JZ9ZWB9AY6Y1ZHW4794Y	cart_01KVF21BZHAQPMVMPMJFST02K8	Gg	Noire	https://s3.eastmarket.africa/eastmarket/image-01KV5JR733EB6YJ4A4G4TNYWNN.jpg	10	variant_01KV5K1Y7ZB131EVPGZ9M407MM	prod_01KV5K1Y66BRSD3K4GDMN4M1YS	Gg	\N	\N	\N	\N	gg	BBBB	\N	Noire	\N	t	t	f	\N	\N	1900	{"value": "1900", "precision": 20}	{}	2026-06-30 23:57:25.952+02	2026-06-30 23:57:44.913+02	2026-06-30 23:57:44.912+02	\N	f	f
cali_01KWCCFKMHZV71KSDPHJQQDR1E	cart_01KVF21BZHAQPMVMPMJFST02K8	Sandales plates pour femmes  (Modèles assortis)	36 / Rouge	https://s3.eastmarket.africa/eastmarket/image-01KVAGYGR5HSSKB5HN5VY7MM8M.jpg	4	variant_01KVAHVT2EBVYQBAVTR9ZSV73R	prod_01KVAHVT1115P37Z781SCQWX1W	Sandales plates pour femmes  (Modèles assortis)	Sandales plates confortables pour femmes, disponibles en plusieurs modèles et coloris élégants (marron, beige, noir, bordeaux). Idéales pour le quotidien.	\N	\N	\N	sandales-plates-pour-femmes-modeles-assortis	\N	\N	36 / Rouge	\N	t	t	f	\N	\N	200	{"value": "200", "precision": 20}	{}	2026-06-30 15:46:15.569+02	2026-07-01 00:10:00.633+02	\N	\N	f	f
cali_01KVAXB136W2PR266YF5CC17DX	cart_01KVAGCKDTWERGJ7WG6JW897EZ	Sandales plates pour femmes  (Modèles assortis)	36 / Noir	https://s3.eastmarket.africa/eastmarket/image-01KVAGYGR5HSSKB5HN5VY7MM8M.jpg	1	variant_01KVAHVT2EKW039PVGG0YMCKJ1	prod_01KVAHVT1115P37Z781SCQWX1W	Sandales plates pour femmes  (Modèles assortis)	Sandales plates confortables pour femmes, disponibles en plusieurs modèles et coloris élégants (marron, beige, noir, bordeaux). Idéales pour le quotidien.	\N	\N	\N	sandales-plates-pour-femmes-modeles-assortis	\N	\N	36 / Noir	\N	t	t	f	\N	\N	200	{"value": "200", "precision": 20}	{}	2026-06-17 15:46:40.614+02	2026-07-06 04:04:17.166+02	2026-07-06 04:04:17.163+02	\N	f	f
cali_01KWTK7N8TAXJTVV9M3XDT03GH	cart_01KWT6EQA1B67FMAWJ43XXT9MW	Soulier de qualité.	37	https://s3.eastmarket.africa/eastmarket/image-01KWT4FXDQ78MMRJQZR3G7FVA4.jpg	1	variant_01KWT4YC09506GRNFD29SZ1RFP	prod_01KWT4YBXAFKGSHX0R820VDJS4	Soulier de qualité.	\N	\N	\N	\N	soulier-de-qualite	\N	\N	37	\N	t	t	f	\N	\N	1000000	{"value": "1000000", "precision": 20}	{}	2026-07-06 04:13:37.178+02	2026-07-06 04:15:44.662+02	2026-07-06 04:15:44.661+02	\N	f	f
cali_01KWTM0EAY2MH8T9P9AWFH07KY	cart_01KWT6EQA1B67FMAWJ43XXT9MW	Soulier de bonne qualité	38	https://s3.eastmarket.africa/eastmarket/image-01KWTKVV2H2M65YENN1QQ6EMKH.jpg	10	variant_01KWTKZBP0ZM5SKYT8FF8TRK05	prod_01KWTKZBN13GNZVP6YNBMAD3VP	Soulier de bonne qualité	\N	\N	\N	\N	soulier-de-bonne-qualite	\N	\N	38	\N	t	t	f	\N	\N	2020	{"value": "2020", "precision": 20}	{}	2026-07-06 04:27:09.278+02	2026-07-06 04:27:55.554+02	2026-07-06 04:27:55.553+02	\N	f	f
cali_01KWTM2BH6WY2FV1VYHG2M6JZ7	cart_01KWT6EQA1B67FMAWJ43XXT9MW	Soulier de bonne qualité	38	https://s3.eastmarket.africa/eastmarket/image-01KWTKVV2H2M65YENN1QQ6EMKH.jpg	1	variant_01KWTKZBP0ZM5SKYT8FF8TRK05	prod_01KWTKZBN13GNZVP6YNBMAD3VP	Soulier de bonne qualité	\N	\N	\N	\N	soulier-de-bonne-qualite	\N	\N	38	\N	t	t	f	\N	\N	2020	{"value": "2020", "precision": 20}	{}	2026-07-06 04:28:11.942+02	2026-07-06 04:28:58.103+02	\N	\N	f	f
cali_01KWXQK18EP8H9S3NE38BRAP1J	cart_01KWXQH6P0G9QEZJTNMVNJQNEP	Soulier de bonne qualité	36	https://s3.eastmarket.africa/eastmarket/image-01KWTKVV2H2M65YENN1QQ6EMKH.jpg	1	variant_01KWTKZBP0CNV7C3N5X7799R31	prod_01KWTKZBN13GNZVP6YNBMAD3VP	Soulier de bonne qualité	\N	\N	\N	\N	soulier-de-bonne-qualite	\N	\N	36	\N	t	t	f	\N	\N	2020	{"value": "2020", "precision": 20}	{}	2026-07-07 09:27:27.502+02	2026-07-07 09:27:31.84+02	2026-07-07 09:27:31.838+02	\N	f	f
cali_01KWXQK867E7VFNRYM5SSW6FAT	cart_01KWXQH6P0G9QEZJTNMVNJQNEP	Soulier de bonne qualité	36	https://s3.eastmarket.africa/eastmarket/image-01KWTKVV2H2M65YENN1QQ6EMKH.jpg	1	variant_01KWTKZBP0CNV7C3N5X7799R31	prod_01KWTKZBN13GNZVP6YNBMAD3VP	Soulier de bonne qualité	\N	\N	\N	\N	soulier-de-bonne-qualite	\N	\N	36	\N	t	t	f	\N	\N	2020	{"value": "2020", "precision": 20}	{}	2026-07-07 09:27:34.6+02	2026-07-07 09:27:34.601+02	\N	\N	f	f
cali_01KXDHH0QD936TR8QY74JKDYPH	cart_01KXDHGKG57TMWKDAB6RT07J3C	Soulier de bonne qualité	38	https://s3.eastmarket.africa/eastmarket/image-01KWTKVV2H2M65YENN1QQ6EMKH.jpg	20	variant_01KWTKZBP0ZM5SKYT8FF8TRK05	prod_01KWTKZBN13GNZVP6YNBMAD3VP	Soulier de bonne qualité	\N	\N	\N	\N	soulier-de-bonne-qualite	\N	\N	38	\N	t	t	f	\N	\N	2020	{"value": "2020", "precision": 20}	{}	2026-07-13 12:49:20.877+02	2026-07-13 12:57:18.606+02	2026-07-13 12:57:18.605+02	\N	f	f
cali_01KXDPX8F9RYZGBKNFDZ3PB8B4	cart_01KXDHGKG57TMWKDAB6RT07J3C	Gg	Noire	https://s3.eastmarket.africa/eastmarket/image-01KV5JR733EB6YJ4A4G4TNYWNN.jpg	10	variant_01KV5K1Y7ZB131EVPGZ9M407MM	prod_01KV5K1Y66BRSD3K4GDMN4M1YS	Gg	\N	\N	\N	\N	gg	BBBB	\N	Noire	\N	t	t	f	\N	\N	1900	{"value": "1900", "precision": 20}	{}	2026-07-13 14:23:24.905+02	2026-07-13 14:23:30.044+02	2026-07-13 14:23:30.044+02	\N	f	f
cali_01KXDPY4PT1VSM9XNSGTF7JTV4	cart_01KXDHGKG57TMWKDAB6RT07J3C	Soulier de bonne qualité	38	https://s3.eastmarket.africa/eastmarket/image-01KWTKVV2H2M65YENN1QQ6EMKH.jpg	10	variant_01KWTKZBP0ZM5SKYT8FF8TRK05	prod_01KWTKZBN13GNZVP6YNBMAD3VP	Soulier de bonne qualité	\N	\N	\N	\N	soulier-de-bonne-qualite	\N	\N	38	\N	t	t	f	\N	\N	2020	{"value": "2020", "precision": 20}	{}	2026-07-13 14:23:53.819+02	2026-07-30 05:31:17.927+02	2026-07-30 05:31:17.925+02	\N	f	f
cali_01KZ3JKN9PVQRMDVR7T0K0XKBJ	cart_01KXDHGKG57TMWKDAB6RT07J3C	Sandales plates pour femmes  (Modèles assortis)	36 / Rouge	https://s3.eastmarket.africa/eastmarket/image-01KVAGYGR5HSSKB5HN5VY7MM8M.jpg	1	variant_01KVAHVT2EBVYQBAVTR9ZSV73R	prod_01KVAHVT1115P37Z781SCQWX1W	Sandales plates pour femmes  (Modèles assortis)	Sandales plates confortables pour femmes, disponibles en plusieurs modèles et coloris élégants (marron, beige, noir, bordeaux). Idéales pour le quotidien.	\N	\N	\N	sandales-plates-pour-femmes-modeles-assortis	\N	\N	36 / Rouge	\N	t	t	f	\N	\N	200	{"value": "200", "precision": 20}	{}	2026-08-03 12:27:15.383+02	2026-08-03 12:33:04.21+02	2026-08-03 12:33:04.208+02	\N	f	f
cali_01KZSMGS1V9HE5MEP153X1CZ0Z	cart_01KZSMFE2TR1GA2RG73BGXCMD9	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	1	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-08-12 02:03:55.579+02	2026-08-12 02:03:55.579+02	\N	\N	f	f
cali_01KZSNW8HAKPXVT94TV7QJ2B19	cart_01KZSNW83S6222HZ28KHMG9EXJ	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	1	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-08-12 02:27:40.459+02	2026-08-12 02:27:40.459+02	\N	\N	f	f
cali_01KZSRP0K65PXN95J3DDNFC944	cart_01KZSRP068BQQP8TQNEB823ZCV	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	2	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-08-12 03:16:41.446+02	2026-08-12 03:16:41.446+02	\N	\N	f	f
cali_01KZSRT7EDA9R27GSVAN2FE7MD	cart_01KZSRT71KMHMWX9DFAXP33T7W	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	1	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-08-12 03:18:59.534+02	2026-08-12 03:18:59.534+02	\N	\N	f	f
cali_01KZSS4BZPRF5A3B1QK2MMF61R	cart_01KZSS4BKPNCHBFWMGN0624ZPN	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	3	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-08-12 03:24:31.862+02	2026-08-12 03:24:31.862+02	\N	\N	f	f
cali_01KZSS6ZG58HE7550XMSP5D5P2	cart_01KZSS6Z30MMS0FNSH6K4H7HKY	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	4	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-08-12 03:25:57.382+02	2026-08-12 03:25:57.382+02	\N	\N	f	f
cali_01KZTFBP65TRGSP69M4PVXMW77	cart_01KZTFBNRPB6DYYAKDVDE4TQPB	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	1	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-08-12 09:53:00.357+02	2026-08-12 09:53:00.357+02	\N	\N	f	f
cali_01KXG833GEEFFRQJYMN452DQBT	cart_01KVAGCKDTWERGJ7WG6JW897EZ	Soulier de bonne qualité	38	https://s3.eastmarket.africa/eastmarket/image-01KWTKVV2H2M65YENN1QQ6EMKH.jpg	1	variant_01KWTKZBP0ZM5SKYT8FF8TRK05	prod_01KWTKZBN13GNZVP6YNBMAD3VP	Soulier de bonne qualité	\N	\N	\N	\N	soulier-de-bonne-qualite	\N	\N	38	\N	t	t	f	\N	\N	2020	{"value": "2020", "precision": 20}	{}	2026-07-14 14:02:11.087+02	2026-08-12 16:21:03.904+02	2026-08-12 16:21:03.901+02	\N	f	f
cali_01M035FE0N54D6NR0P10SRS7ZP	cart_01KXDHGKG57TMWKDAB6RT07J3C	Gg	Noire	https://s3.eastmarket.africa/eastmarket/image-01KV5JR733EB6YJ4A4G4TNYWNN.jpg	8	variant_01KV5K1Y7ZB131EVPGZ9M407MM	prod_01KV5K1Y66BRSD3K4GDMN4M1YS	Gg	\N	\N	\N	\N	gg	BBBB	\N	Noire	\N	t	t	f	\N	\N	1900	{"value": "1900", "precision": 20}	{}	2026-08-15 18:53:27.19+02	2026-08-15 18:53:27.19+02	\N	\N	f	f
cali_01KZV5V2JXKDTSBAHYPA3VD8PV	cart_01KVAGCKDTWERGJ7WG6JW897EZ	Gg	Rouge	https://s3.eastmarket.africa/eastmarket/image-01KV5JR733EB6YJ4A4G4TNYWNN.jpg	2	variant_01KV5K1Y7YYFQVWGAWEBNRGXB9	prod_01KV5K1Y66BRSD3K4GDMN4M1YS	Gg	\N	\N	\N	\N	gg	\N	\N	Rouge	\N	t	t	f	\N	\N	1000	{"value": "1000", "precision": 20}	{}	2026-08-12 16:25:53.246+02	2026-08-12 16:28:50.912+02	2026-08-12 16:28:50.911+02	\N	f	f
cali_01KZYEXVDP429ZN0EDCH84BXM5	cart_01KVAGCKDTWERGJ7WG6JW897EZ	Gg	Noire	https://s3.eastmarket.africa/eastmarket/image-01KV5JR733EB6YJ4A4G4TNYWNN.jpg	1	variant_01KV5K1Y7ZB131EVPGZ9M407MM	prod_01KV5K1Y66BRSD3K4GDMN4M1YS	Gg	\N	\N	\N	\N	gg	BBBB	\N	Noire	\N	t	t	f	\N	\N	1900	{"value": "1900", "precision": 20}	{}	2026-08-13 23:02:24.695+02	2026-08-13 23:02:24.695+02	\N	\N	f	f
\.


--
-- Data for Name: cart_line_item_adjustment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart_line_item_adjustment (id, description, promotion_id, code, amount, raw_amount, provider_id, metadata, created_at, updated_at, deleted_at, item_id, is_tax_inclusive) FROM stdin;
caliadj_01KZSMGZR16TB8ABTXR3G3SA10	\N	promo_01KZSMEY4VRFZ2AXHA9GMJZBTC	EM-O9X2TFZJ	1000	{"value": "1000", "precision": 20}	\N	\N	2026-08-12 02:04:02.434+02	2026-08-12 02:04:02.434+02	\N	cali_01KZSMGS1V9HE5MEP153X1CZ0Z	f
caliadj_01KZSNW8NT8SD9JANASCJMYP8R	\N	promo_01KZSNVQVHV4YR8R403X1ZZPDG	FLASH-LP02E1	2000	{"value": "2000", "precision": 20}	\N	\N	2026-08-12 02:27:40.603+02	2026-08-12 03:15:06.485+02	2026-08-12 03:15:06.484+02	cali_01KZSNW8HAKPXVT94TV7QJ2B19	f
caliadj_01KZSRKC6NP7PW45KWDPS1D2KA	\N	promo_01KZSNVQVHV4YR8R403X1ZZPDG	FLASH-LP02E1	2000	{"value": "2000", "precision": 20}	\N	\N	2026-08-12 03:15:15.029+02	2026-08-12 03:15:15.029+02	\N	cali_01KZSNW8HAKPXVT94TV7QJ2B19	f
caliadj_01KZSRK3VGZSGVDRDDQTDZM6T3	\N	promo_01KZSNVQVHV4YR8R403X1ZZPDG	FLASH-LP02E1	2000	{"value": "2000", "precision": 20}	\N	\N	2026-08-12 03:15:06.48+02	2026-08-12 03:15:15.031+02	2026-08-12 03:15:15.03+02	cali_01KZSNW8HAKPXVT94TV7QJ2B19	f
caliadj_01KZSRP0QRACQ7F6AB31JH09CF	\N	promo_01KZSNVQVHV4YR8R403X1ZZPDG	FLASH-LP02E1	4000	{"value": "4000", "precision": 20}	\N	\N	2026-08-12 03:16:41.592+02	2026-08-12 03:16:56.536+02	2026-08-12 03:16:56.535+02	cali_01KZSRP0K65PXN95J3DDNFC944	f
caliadj_01KZSRPGBK0KFEGH4QZS4AY6G4	\N	promo_01KZSNVQVHV4YR8R403X1ZZPDG	FLASH-LP02E1	4000	{"value": "4000", "precision": 20}	\N	\N	2026-08-12 03:16:57.587+02	2026-08-12 03:16:57.587+02	\N	cali_01KZSRP0K65PXN95J3DDNFC944	f
caliadj_01KZSRPFANW0V9E4JQBHWCSCKB	\N	promo_01KZSNVQVHV4YR8R403X1ZZPDG	FLASH-LP02E1	4000	{"value": "4000", "precision": 20}	\N	\N	2026-08-12 03:16:56.533+02	2026-08-12 03:16:57.59+02	2026-08-12 03:16:57.59+02	cali_01KZSRP0K65PXN95J3DDNFC944	f
caliadj_01KZSRT7K2PCSM4CA1F7Q13HV4	\N	promo_01KZSNVQVHV4YR8R403X1ZZPDG	FLASH-LP02E1	2000	{"value": "2000", "precision": 20}	\N	\N	2026-08-12 03:18:59.682+02	2026-08-12 03:19:00.095+02	2026-08-12 03:19:00.093+02	cali_01KZSRT7EDA9R27GSVAN2FE7MD	f
caliadj_01KZSRT8TEY0VA0FXHVA894NC9	\N	promo_01KZSNVQVHV4YR8R403X1ZZPDG	FLASH-LP02E1	2000	{"value": "2000", "precision": 20}	\N	\N	2026-08-12 03:19:00.943+02	2026-08-12 03:19:00.943+02	\N	cali_01KZSRT7EDA9R27GSVAN2FE7MD	f
caliadj_01KZSRT7ZTX9GD7G98W98EC930	\N	promo_01KZSNVQVHV4YR8R403X1ZZPDG	FLASH-LP02E1	2000	{"value": "2000", "precision": 20}	\N	\N	2026-08-12 03:19:00.09+02	2026-08-12 03:19:00.945+02	2026-08-12 03:19:00.945+02	cali_01KZSRT7EDA9R27GSVAN2FE7MD	f
caliadj_01KZSS4C3JV7GFG54CQ037H5QD	\N	promo_01KZSNVQVHV4YR8R403X1ZZPDG	FLASH-LP02E1	6000	{"value": "6000", "precision": 20}	\N	\N	2026-08-12 03:24:31.987+02	2026-08-12 03:24:32.759+02	2026-08-12 03:24:32.758+02	cali_01KZSS4BZPRF5A3B1QK2MMF61R	f
caliadj_01KZSS4DP6KGF6QF5R2CSES3PT	\N	promo_01KZSNVQVHV4YR8R403X1ZZPDG	FLASH-LP02E1	6000	{"value": "6000", "precision": 20}	\N	\N	2026-08-12 03:24:33.606+02	2026-08-12 03:24:33.606+02	\N	cali_01KZSS4BZPRF5A3B1QK2MMF61R	f
caliadj_01KZSS4CVM4J6XNK6RKMHTET1F	\N	promo_01KZSNVQVHV4YR8R403X1ZZPDG	FLASH-LP02E1	6000	{"value": "6000", "precision": 20}	\N	\N	2026-08-12 03:24:32.756+02	2026-08-12 03:24:33.608+02	2026-08-12 03:24:33.608+02	cali_01KZSS4BZPRF5A3B1QK2MMF61R	f
caliadj_01KZSS6ZM7TM22KDM2MN1SXR1A	\N	promo_01KZSNVQVHV4YR8R403X1ZZPDG	FLASH-LP02E1	8000	{"value": "8000", "precision": 20}	\N	\N	2026-08-12 03:25:57.512+02	2026-08-12 03:25:57.922+02	2026-08-12 03:25:57.921+02	cali_01KZSS6ZG58HE7550XMSP5D5P2	f
caliadj_01KZSS70SP1GQZS0XKG1W8P03D	\N	promo_01KZSNVQVHV4YR8R403X1ZZPDG	FLASH-LP02E1	8000	{"value": "8000", "precision": 20}	\N	\N	2026-08-12 03:25:58.71+02	2026-08-12 03:25:58.71+02	\N	cali_01KZSS6ZG58HE7550XMSP5D5P2	f
caliadj_01KZSS700ZS6N9TWWF82GHD59C	\N	promo_01KZSNVQVHV4YR8R403X1ZZPDG	FLASH-LP02E1	8000	{"value": "8000", "precision": 20}	\N	\N	2026-08-12 03:25:57.919+02	2026-08-12 03:25:58.712+02	2026-08-12 03:25:58.712+02	cali_01KZSS6ZG58HE7550XMSP5D5P2	f
\.


--
-- Data for Name: cart_line_item_tax_line; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart_line_item_tax_line (id, description, tax_rate_id, code, rate, provider_id, metadata, created_at, updated_at, deleted_at, item_id) FROM stdin;
\.


--
-- Data for Name: cart_payment_collection; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart_payment_collection (cart_id, payment_collection_id, id, created_at, updated_at, deleted_at) FROM stdin;
cart_01KSR17JJKRN19AW6DGG1ZNZXC	pay_col_01KSWZ94EQ5D38QNM7MST6HWZG	capaycol_01KSWZ94F71CJBTV1JKKCGV9JK	2026-05-30 19:35:31.814363+02	2026-05-30 19:35:31.814363+02	\N
cart_01KSYNPXZ7GKJRHYWE8HXZQPEJ	pay_col_01KSYNR39BDXK25THEAVTSYRGS	capaycol_01KSYNR39SF41T5FEP4V0C2P6R	2026-05-31 11:27:25.2412+02	2026-05-31 11:27:25.2412+02	\N
cart_01KSYPV5SG04S1KMPP10R93K65	pay_col_01KSYPW2KYHN8K2GHSVKVXMBZG	capaycol_01KSYPW2M7PJF7880CAJG4YCY9	2026-05-31 11:47:04.199402+02	2026-05-31 11:47:04.199402+02	\N
cart_01KSYRTG3P2TYAY5NJK34GCSQC	pay_col_01KSYZ51Q4494HTGSD1TJ8A5D2	capaycol_01KSYZ51Q99VMFRWW83Y516QYS	2026-05-31 14:11:46.792879+02	2026-05-31 14:11:46.792879+02	\N
cart_01KSYZ93PAWAQ3YMSX95CPEDAW	pay_col_01KSYZ9NDFGXQM8FA9J9W7D3JD	capaycol_01KSYZ9NDPNES8X6VXTACWF64C	2026-05-31 14:14:18.038228+02	2026-05-31 14:14:18.038228+02	\N
cart_01KSYZD7RA6NWZ1QPAGBP73146	pay_col_01KSYZEH789VJTB2YQF9KHSJWZ	capaycol_01KSYZEH7D5ASGNFQ5KQSMMF39	2026-05-31 14:16:57.581248+02	2026-05-31 14:16:57.581248+02	\N
cart_01KSZ01P234X82AKV9N28KZVJA	pay_col_01KSZ02556JBB1TV51D0S5K6Y9	capaycol_01KSZ0255FH7DW0847J6BA1821	2026-05-31 14:27:40.590883+02	2026-05-31 14:27:40.590883+02	\N
cart_01KSZ03JDPKWSSPAQ2AB3D3A5B	pay_col_01KSZ040JFEPH8MCEFB8KNTFRR	capaycol_01KSZ040JT80CJZG193E0NEQ6G	2026-05-31 14:28:41.433802+02	2026-05-31 14:28:41.433802+02	\N
cart_01KSZ0TTA6QMT1NTEB871F845G	pay_col_01KSZ0VAW9SMZTJHEJ0T5M6QHJ	capaycol_01KSZ0VAWTJB18094G722RGKCX	2026-05-31 14:41:25.657922+02	2026-05-31 14:41:25.657922+02	\N
cart_01KT1VZFSW5FDQCERA8BX242EF	pay_col_01KT6M0W172PCB6JW5MG36TPT6	capaycol_01KT6M0W1HV9T18HG2SMKEKX90	2026-06-03 13:31:11.024627+02	2026-06-03 13:31:11.024627+02	\N
cart_01KVAGCKDTWERGJ7WG6JW897EZ	pay_col_01KVAYBKQD47ZD40RDE63AACSW	capaycol_01KVAYBKQQ29TQMSWHRA16QP12	2026-06-17 16:04:28.278574+02	2026-06-17 16:04:28.278574+02	\N
cart_01KVDKH2HKR1RF5YJFXH1AQP8S	pay_col_01KVDNF9Z3Q1QC438AY9WDDYMG	capaycol_01KVDNF9ZB1AA3RQ70XYMWRE4C	2026-06-18 17:26:55.466917+02	2026-06-18 17:26:55.466917+02	\N
cart_01KVF21BZHAQPMVMPMJFST02K8	pay_col_01KVF22BN4S82ZGGZQ3ESSFBBV	capaycol_01KVF22BNH9ECNBAJ3M5S4YPY7	2026-06-19 06:26:17.136817+02	2026-06-19 06:26:17.136817+02	\N
cart_01KXDHGKG57TMWKDAB6RT07J3C	pay_col_01KXDHMRCGTBWARECQFFF32YNB	capaycol_01KXDHMRCX4MVRHSFTZV3VA4B1	2026-07-13 12:51:23.420469+02	2026-07-13 12:51:23.420469+02	\N
cart_01KZSNW83S6222HZ28KHMG9EXJ	pay_col_01KZSRKCBR0ZN38RXKZRW228SQ	capaycol_01KZSRKCC5E9N7SG03FYSNGCAB	2026-08-12 03:15:15.205187+02	2026-08-12 03:15:15.205187+02	\N
cart_01KZSRP068BQQP8TQNEB823ZCV	pay_col_01KZSRPGGP387KFPAG78BHCSAE	capaycol_01KZSRPGGZYWRT6CWAFZSSGCXB	2026-08-12 03:16:57.759483+02	2026-08-12 03:16:57.759483+02	\N
cart_01KZSRT71KMHMWX9DFAXP33T7W	pay_col_01KZSRT8Y4S969FXBXAS1AY8VQ	capaycol_01KZSRT8YE4A9RZQP4B6WFWSNC	2026-08-12 03:19:01.06988+02	2026-08-12 03:19:01.06988+02	\N
cart_01KZSS4BKPNCHBFWMGN0624ZPN	pay_col_01KZSS4DSR9SKHCTMM0M8PPCSR	capaycol_01KZSS4DT3R6090HNSR4BV4YYN	2026-08-12 03:24:33.730646+02	2026-08-12 03:24:33.730646+02	\N
cart_01KZSS6Z30MMS0FNSH6K4H7HKY	pay_col_01KZSS70X45RCV80Q6K7RJCTRD	capaycol_01KZSS70XFFGCY887W59SE0P16	2026-08-12 03:25:58.831485+02	2026-08-12 03:25:58.831485+02	\N
cart_01KZTFBNRPB6DYYAKDVDE4TQPB	pay_col_01KZTFBQH0TFC3M9BSP14R8WY4	capaycol_01KZTFBQHG38QSG7Q00BAEGNDH	2026-08-12 09:53:01.743479+02	2026-08-12 09:53:01.743479+02	\N
\.


--
-- Data for Name: cart_promotion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart_promotion (cart_id, promotion_id, id, created_at, updated_at, deleted_at) FROM stdin;
cart_01KZSMFE2TR1GA2RG73BGXCMD9	promo_01KZSMEY4VRFZ2AXHA9GMJZBTC	cartpromo_01KZSMGZR6Q532K8CH4GGGQE5J	2026-08-12 02:04:02.438326+02	2026-08-12 02:04:02.438326+02	\N
cart_01KZSNW83S6222HZ28KHMG9EXJ	promo_01KZSNVQVHV4YR8R403X1ZZPDG	cartpromo_01KZSRKC6Z5NH67H7NT53WN4CW	2026-08-12 02:27:40.608796+02	2026-08-12 03:15:15.037+02	\N
cart_01KZSRP068BQQP8TQNEB823ZCV	promo_01KZSNVQVHV4YR8R403X1ZZPDG	cartpromo_01KZSRPGC35GSA968Z3ZMRAS0F	2026-08-12 03:16:41.602418+02	2026-08-12 03:16:57.599+02	\N
cart_01KZSRT71KMHMWX9DFAXP33T7W	promo_01KZSNVQVHV4YR8R403X1ZZPDG	cartpromo_01KZSRT8V0Z7FAG26Q0C56QAM3	2026-08-12 03:18:59.690391+02	2026-08-12 03:19:00.957+02	\N
cart_01KZSS4BKPNCHBFWMGN0624ZPN	promo_01KZSNVQVHV4YR8R403X1ZZPDG	cartpromo_01KZSS4DPNMQ9Y7YXQHXJGJ9H3	2026-08-12 03:24:31.993978+02	2026-08-12 03:24:33.618+02	\N
cart_01KZSS6Z30MMS0FNSH6K4H7HKY	promo_01KZSNVQVHV4YR8R403X1ZZPDG	cartpromo_01KZSS70T3KXZYED4MNWAKVA9G	2026-08-12 03:25:57.518226+02	2026-08-12 03:25:58.719+02	\N
\.


--
-- Data for Name: cart_shipping_method; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart_shipping_method (id, cart_id, name, description, amount, raw_amount, is_tax_inclusive, shipping_option_id, data, metadata, created_at, updated_at, deleted_at) FROM stdin;
casm_01KSWZ8YXPS71BVW3D1RR29ESW	cart_01KSR17JJKRN19AW6DGG1ZNZXC	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-05-30 19:35:26.134+02	2026-05-30 19:35:26.134+02	\N
casm_01KSYNQN8N5MGP3XVNAHC9JEEM	cart_01KSYNPXZ7GKJRHYWE8HXZQPEJ	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-05-31 11:27:10.869+02	2026-05-31 11:27:10.869+02	\N
casm_01KSYPVQS4JD6TZHHV4CQB7X4J	cart_01KSYPV5SG04S1KMPP10R93K65	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-05-31 11:46:53.092+02	2026-05-31 11:46:53.092+02	\N
casm_01KSYZ4TEE59TV4AEPKQP34T95	cart_01KSYRTG3P2TYAY5NJK34GCSQC	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-05-31 14:11:39.342+02	2026-05-31 14:11:39.342+02	\N
casm_01KSYZ9FREEGNP2128JQ3BPX41	cart_01KSYZ93PAWAQ3YMSX95CPEDAW	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-05-31 14:14:12.238+02	2026-05-31 14:14:12.238+02	\N
casm_01KSYZE570W6VE7MGYTYVWFXG8	cart_01KSYZD7RA6NWZ1QPAGBP73146	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-05-31 14:16:45.28+02	2026-05-31 14:16:45.28+02	\N
casm_01KSYZE4KNB9SHH2PY276S82HS	cart_01KSYZD7RA6NWZ1QPAGBP73146	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-05-31 14:16:44.661+02	2026-05-31 14:16:45.282+02	2026-05-31 14:16:45.282+02
casm_01KSZ0216C3TZSEZ6G0N8WKGKV	cart_01KSZ01P234X82AKV9N28KZVJA	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-05-31 14:27:36.524+02	2026-05-31 14:27:36.524+02	\N
casm_01KSZ03WAN2JX5E24CATAWA6A3	cart_01KSZ03JDPKWSSPAQ2AB3D3A5B	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-05-31 14:28:37.077+02	2026-05-31 14:28:37.077+02	\N
casm_01KSZ0V6RCRX8YH1WNZCG2H6T4	cart_01KSZ0TTA6QMT1NTEB871F845G	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-05-31 14:41:21.421+02	2026-05-31 14:41:21.421+02	\N
casm_01KT1W1RS6Q9TRY13GHMN71DQZ	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-01 17:15:16.902+02	2026-06-01 17:15:44.381+02	2026-06-01 17:15:44.38+02
casm_01KT1W2KKZ6T2ZW5T8N8PC852Q	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-01 17:15:44.383+02	2026-06-01 17:47:12.021+02	2026-06-01 17:47:12.021+02
casm_01KT1XW70MDZ5PDJWT9KGPYJ43	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-01 17:47:12.02+02	2026-06-01 17:51:33.596+02	2026-06-01 17:51:33.596+02
casm_01KT1Y46EVJ557T41XY6K3SPHF	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-01 17:51:33.595+02	2026-06-01 18:07:25.336+02	2026-06-01 18:07:25.335+02
casm_01KT1Z17WM84MT7EAVS7NTV47X	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-01 18:07:25.332+02	2026-06-01 18:08:24.868+02	2026-06-01 18:08:24.868+02
casm_01KT1Z3214JHNJ1KC1QJ9T5XJS	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-01 18:08:24.868+02	2026-06-01 18:16:50.603+02	2026-06-01 18:16:50.603+02
casm_01KT1ZJFX9GQN35CN9SYXCTCZD	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-01 18:16:50.601+02	2026-06-01 18:18:24.9+02	2026-06-01 18:18:24.9+02
casm_01KT1ZNC03QFZCPZ6KQVB5H90M	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-01 18:18:24.899+02	2026-06-01 18:19:06.501+02	2026-06-01 18:19:06.501+02
casm_01KT1ZPMM4JPQKAV9JZ6ZNQ3AQ	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-01 18:19:06.5+02	2026-06-01 18:28:30.036+02	2026-06-01 18:28:30.035+02
casm_01KT207TYHVBMQPP50DTE5QWMX	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-01 18:28:30.034+02	2026-06-01 18:29:00.363+02	2026-06-01 18:29:00.363+02
casm_01KT208RJAZ6CDAM2N1YP6QE3Q	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-01 18:29:00.362+02	2026-06-03 13:02:26.702+02	2026-06-03 13:02:26.702+02
casm_01KT6JC84D1G52PHV2X6Q9NWPH	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-03 13:02:26.701+02	2026-06-03 13:12:32.429+02	2026-06-03 13:12:32.429+02
casm_01KT6JYQNBRFFQN16A1TAHVPYY	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-03 13:12:32.427+02	2026-06-03 13:14:28.251+02	2026-06-03 13:14:28.251+02
casm_01KT6K28RT8F5XS3KN31QBN1GX	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-03 13:14:28.25+02	2026-06-03 13:51:53.702+02	2026-06-03 13:51:53.701+02
casm_01KT6N6SK414PYQJNPFM2DEMGY	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-03 13:51:53.7+02	2026-06-03 15:12:02.783+02	2026-06-03 15:12:02.782+02
casm_01KT6SSHYWTKRJ4XCKSAWBET3V	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-03 15:12:02.78+02	2026-06-03 15:51:09.669+02	2026-06-03 15:51:09.668+02
casm_01KT6W15V1MPZE2E8DM1X20QC3	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-03 15:51:09.665+02	2026-06-03 16:54:35.142+02	2026-06-03 16:54:35.141+02
casm_01KT6ZNA43PFQ6ZG8184TCA5A9	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-03 16:54:35.14+02	2026-06-03 16:54:35.722+02	2026-06-03 16:54:35.722+02
casm_01KT6ZNAP8E99SSAYG9WRA63AY	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-03 16:54:35.72+02	2026-06-03 19:19:20.752+02	2026-06-03 19:19:20.751+02
casm_01KT77YC59FTBVYFPA59M4NSY1	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-03 19:19:20.745+02	2026-06-03 20:02:28.25+02	2026-06-03 20:02:28.25+02
casm_01KT7ADB0S8P9RVW61N6Q04YMY	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-03 20:02:28.249+02	2026-06-04 11:17:08.51+02	2026-06-04 11:17:08.51+02
casm_01KT8YR50VN26J82F49WZ2FW57	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 11:17:08.508+02	2026-06-04 12:50:12.187+02	2026-06-04 12:50:12.187+02
casm_01KT942HTTCX749K0PJQ5CGE70	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 12:50:12.186+02	2026-06-04 12:54:15.443+02	2026-06-04 12:54:15.443+02
casm_01KT949ZCH33DQFXER3CH99EZP	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 12:54:15.441+02	2026-06-04 12:56:52.696+02	2026-06-04 12:56:52.695+02
casm_01KT94ERYP03QA0H65SGBTGVFF	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 12:56:52.694+02	2026-06-04 13:19:39.317+02	2026-06-04 13:19:39.316+02
casm_01KT964BZM7BFCVWC6ZTTT0KHW	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 13:26:08.885+02	2026-06-04 13:44:31.453+02	2026-06-04 13:44:31.452+02
casm_01KT95RFHH6R81CJ54E93XGEY9	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 13:19:39.314+02	2026-06-04 13:26:08.888+02	2026-06-04 13:26:08.888+02
casm_01KT9760PNEY1Q9PF4CAAKZ982	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 13:44:31.446+02	2026-06-04 13:44:41.268+02	2026-06-04 13:44:41.268+02
casm_01KT976A9HEMN1E9JMG4JKMFRV	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 13:44:41.266+02	2026-06-04 13:45:09.516+02	2026-06-04 13:45:09.516+02
casm_01KT9775WA1H61ETMENAK0FQXN	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 13:45:09.514+02	2026-06-04 13:58:33.043+02	2026-06-04 13:58:33.043+02
casm_01KT97ZPJGG9YP9P2TEHFAMWYW	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 13:58:33.041+02	2026-06-04 14:01:28.413+02	2026-06-04 14:01:28.412+02
casm_01KT9851TVR984VJ2M73QS8V02	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 14:01:28.411+02	2026-06-04 14:08:59.037+02	2026-06-04 14:08:59.037+02
casm_01KT98JSWVTGHW0BNY2XTA19NY	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 14:08:59.036+02	2026-06-04 14:18:30.59+02	2026-06-04 14:18:30.59+02
casm_01KT99481W1MV648SVHERN4GTT	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 14:18:30.588+02	2026-06-04 14:23:54.894+02	2026-06-04 14:23:54.893+02
casm_01KT99E4RB2EHWK2MKGQJJ4R66	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 14:23:54.891+02	2026-06-04 14:24:44.671+02	2026-06-04 14:24:44.671+02
casm_01KT99FNBX77YDTAX751VW1RGF	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 14:24:44.669+02	2026-06-04 14:26:54.832+02	2026-06-04 14:26:54.832+02
casm_01KT99KMFB7X6P5H4APH97MZBG	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 14:26:54.828+02	2026-06-04 14:27:31.479+02	2026-06-04 14:27:31.479+02
casm_01KT99MR8MDNJ47MJ6V629K5F0	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 14:27:31.476+02	2026-06-04 14:40:04.253+02	2026-06-04 14:40:04.253+02
casm_01KT9ABQCWN09JPX4WKFTXA03E	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 14:40:04.252+02	2026-06-04 14:43:20.128+02	2026-06-04 14:43:20.128+02
casm_01KT9AHPNYTAVEPVQ20JFKWJRR	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 14:43:20.126+02	2026-06-04 15:01:02.083+02	2026-06-04 15:01:02.083+02
casm_01KT9BJ3R257WEB3FNKRMBCH95	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 15:01:02.082+02	2026-06-04 15:12:07.758+02	2026-06-04 15:12:07.757+02
casm_01KT9C6DTBF1T6726N02HF9VM4	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 15:12:07.756+02	2026-06-04 15:27:30.754+02	2026-06-04 15:27:30.754+02
casm_01KT9D2K5Z83QRJVBQ0M8WW5H8	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 15:27:30.751+02	2026-06-04 15:27:48.569+02	2026-06-04 15:27:48.569+02
casm_01KT9D34JR60HPCDRC8YT4C21W	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 15:27:48.568+02	2026-06-04 21:40:56.867+02	2026-06-04 21:40:56.866+02
casm_01KTA2EC51V4JVRQKD1BFCPQ9A	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 21:40:56.865+02	2026-06-04 21:43:03.439+02	2026-06-04 21:43:03.438+02
casm_01KTA2J7RDF3EM0KP33SAK2T2B	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 21:43:03.437+02	2026-06-04 23:44:35.504+02	2026-06-04 23:44:35.503+02
casm_01KTA9GRXCP9VT1XNR3N3438AE	cart_01KT1VZFSW5FDQCERA8BX242EF	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-06-04 23:44:35.501+02	2026-06-05 00:31:31.991+02	2026-06-05 00:31:31.991+02
casm_01KTACPMQY9WS6FJH4GW7FJD7S	cart_01KT1VZFSW5FDQCERA8BX242EF	Express	\N	1	{"value": "1", "precision": 20}	f	so_01KTACDA0EX08JWS75B4SW1BDG	{}	\N	2026-06-05 00:40:13.566+02	2026-06-05 01:18:47.793+02	2026-06-05 01:18:47.792+02
casm_01KTAEX8QE8PWTFNJ754BFS7AM	cart_01KT1VZFSW5FDQCERA8BX242EF	Express	\N	1	{"value": "1", "precision": 20}	f	so_01KTACDA0EX08JWS75B4SW1BDG	{}	\N	2026-06-05 01:18:47.79+02	2026-06-05 01:21:54.323+02	2026-06-05 01:21:54.323+02
casm_01KTAFER3W377BE5HMPMDVHNDN	cart_01KT1VZFSW5FDQCERA8BX242EF	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-05 01:28:20.604+02	2026-06-05 10:10:39.006+02	2026-06-05 10:10:39.005+02
casm_01KTBDB40TMV69PFY6ES4Z0RBW	cart_01KT1VZFSW5FDQCERA8BX242EF	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-05 10:10:39.003+02	2026-06-05 10:18:30.89+02	2026-06-05 10:18:30.89+02
casm_01KTBDSGV8VZEBKWZFP0582X0X	cart_01KT1VZFSW5FDQCERA8BX242EF	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-05 10:18:30.888+02	2026-06-05 10:20:41.155+02	2026-06-05 10:20:41.154+02
casm_01KTBDXG201H0M59TEXDXE8JVG	cart_01KT1VZFSW5FDQCERA8BX242EF	Standart	\N	10	{"value": "10", "precision": 20}	f	so_01KTAFNNF59QWDVTRF6X6WJ9RG	{}	\N	2026-06-05 10:20:41.152+02	2026-06-05 10:27:33.521+02	2026-06-05 10:27:33.521+02
casm_01KTBEA2REN63KRT6BA3JGRXBV	cart_01KT1VZFSW5FDQCERA8BX242EF	Standart	\N	10	{"value": "10", "precision": 20}	f	so_01KTAFNNF59QWDVTRF6X6WJ9RG	{}	\N	2026-06-05 10:27:33.519+02	2026-06-05 10:34:58.497+02	2026-06-05 10:34:58.496+02
casm_01KTBEQN9Z4CQ6D3BNAD29CEDV	cart_01KT1VZFSW5FDQCERA8BX242EF	Standart	\N	10	{"value": "10", "precision": 20}	f	so_01KTAFNNF59QWDVTRF6X6WJ9RG	{}	\N	2026-06-05 10:34:58.495+02	2026-06-05 20:10:42.659+02	2026-06-05 20:10:42.658+02
casm_01KTCFNVV00R0TZPREY6WM8579	cart_01KT1VZFSW5FDQCERA8BX242EF	Standart	\N	10	{"value": "10", "precision": 20}	f	so_01KTAFNNF59QWDVTRF6X6WJ9RG	{}	\N	2026-06-05 20:10:42.656+02	2026-06-05 20:47:21.885+02	2026-06-05 20:47:21.885+02
casm_01KTCHRZGVXHRVK7QE57DAGVJ0	cart_01KT1VZFSW5FDQCERA8BX242EF	Standart	\N	10	{"value": "10", "precision": 20}	f	so_01KTAFNNF59QWDVTRF6X6WJ9RG	{}	\N	2026-06-05 20:47:21.883+02	2026-06-05 20:49:38.591+02	2026-06-05 20:49:38.591+02
casm_01KTCHX50X404524EFKXB8RMR0	cart_01KT1VZFSW5FDQCERA8BX242EF	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-05 20:49:38.589+02	2026-06-05 20:54:49.918+02	2026-06-05 20:54:49.917+02
casm_01KTCJ6N1R0X69TRBZHPEQ6PK2	cart_01KT1VZFSW5FDQCERA8BX242EF	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-05 20:54:49.912+02	2026-06-05 20:55:35.436+02	2026-06-05 20:55:35.435+02
casm_01KTCJ81G744D51Q9SR3097JMT	cart_01KT1VZFSW5FDQCERA8BX242EF	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-05 20:55:35.432+02	2026-06-06 12:00:49.464+02	2026-06-06 12:00:49.463+02
casm_01KTE68R1K01HRM3Q24F14VPNK	cart_01KT1VZFSW5FDQCERA8BX242EF	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-06 12:04:44.467+02	2026-06-06 14:05:12.636+02	2026-06-06 14:05:12.636+02
casm_01KTE61JHPAF1DDKV6R2R500NH	cart_01KT1VZFSW5FDQCERA8BX242EF	Standart	\N	10	{"value": "10", "precision": 20}	f	so_01KTAFNNF59QWDVTRF6X6WJ9RG	{}	\N	2026-06-06 12:00:49.463+02	2026-06-06 12:04:44.468+02	2026-06-06 12:04:44.468+02
casm_01KTED5ASVX2BHTNKYGC2172YT	cart_01KT1VZFSW5FDQCERA8BX242EF	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-06 14:05:12.635+02	2026-06-06 14:05:12.635+02	\N
casm_01KVATNKS19XRVYW7WC81RQMB6	cart_01KVAGCKDTWERGJ7WG6JW897EZ	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-17 15:00:01.698+02	2026-06-17 15:47:01.547+02	2026-06-17 15:47:01.547+02
casm_01KVAXBNHAGQMS28SE5XFEC5HJ	cart_01KVAGCKDTWERGJ7WG6JW897EZ	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-17 15:47:01.547+02	2026-06-17 15:54:42.424+02	2026-06-17 15:54:42.424+02
casm_01KVAXSQKQR9VQYNRXSB73VMDA	cart_01KVAGCKDTWERGJ7WG6JW897EZ	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-17 15:54:42.423+02	2026-06-17 15:58:56.142+02	2026-06-17 15:58:56.142+02
casm_01KVAY1FCDXR5PTE01SA4FR65R	cart_01KVAGCKDTWERGJ7WG6JW897EZ	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-17 15:58:56.142+02	2026-06-17 16:14:09.367+02	2026-06-17 16:14:09.366+02
casm_01KVAYXB6J424X9ARN1634MWHT	cart_01KVAGCKDTWERGJ7WG6JW897EZ	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-17 16:14:09.363+02	2026-06-17 18:17:23.271+02	2026-06-17 18:17:23.271+02
casm_01KVDNB4MG9GTY8ZZ6Y74QEBTR	cart_01KVDKH2HKR1RF5YJFXH1AQP8S	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-18 17:24:38.929+02	2026-06-18 17:26:36.57+02	2026-06-18 17:26:36.569+02
casm_01KVDNEQGQ69GPQZ54WQJ83JSG	cart_01KVDKH2HKR1RF5YJFXH1AQP8S	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-18 17:26:36.568+02	2026-06-18 17:43:18.806+02	2026-06-18 17:43:18.805+02
casm_01KVDPDA8MPZJJYR66FPF7K5CF	cart_01KVDKH2HKR1RF5YJFXH1AQP8S	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-18 17:43:18.804+02	2026-06-19 05:08:10.615+02	2026-06-19 05:08:10.615+02
casm_01KVEYBZ5JQW8HVD9YBSKA1DPW	cart_01KVDKH2HKR1RF5YJFXH1AQP8S	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-19 05:21:37.714+02	2026-06-19 05:21:37.714+02	\N
casm_01KVEXKAZKYCYCW6JM02GKPER0	cart_01KVDKH2HKR1RF5YJFXH1AQP8S	Standart	\N	10	{"value": "10", "precision": 20}	f	so_01KTAFNNF59QWDVTRF6X6WJ9RG	{}	\N	2026-06-19 05:08:10.612+02	2026-06-19 05:21:37.716+02	2026-06-19 05:21:37.715+02
casm_01KVF21RJAXTR3Z67Y88DZFR3H	cart_01KVF21BZHAQPMVMPMJFST02K8	Standart	\N	10	{"value": "10", "precision": 20}	f	so_01KTAFNNF59QWDVTRF6X6WJ9RG	{}	\N	2026-06-19 06:25:57.579+02	2026-06-19 06:26:59.321+02	2026-06-19 06:26:59.321+02
casm_01KVF23MVQQ8DNEHFM2KVBAEY0	cart_01KVF21BZHAQPMVMPMJFST02K8	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-19 06:26:59.319+02	2026-06-27 05:02:16.493+02	2026-06-27 05:02:16.493+02
casm_01KW3GE956PDBJ15N7J8CKR31P	cart_01KVF21BZHAQPMVMPMJFST02K8	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-27 05:02:16.487+02	2026-06-30 23:57:51.218+02	2026-06-30 23:57:51.218+02
casm_01KWD8KQZMK3DZZBEM07ZEE974	cart_01KVF21BZHAQPMVMPMJFST02K8	Standart	\N	10	{"value": "10", "precision": 20}	f	so_01KTAFNNF59QWDVTRF6X6WJ9RG	{}	\N	2026-06-30 23:57:51.221+02	2026-06-30 23:57:53.418+02	2026-06-30 23:57:53.418+02
casm_01KWD8KT48FWMSQ1X3C7XHDGAP	cart_01KVF21BZHAQPMVMPMJFST02K8	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-30 23:57:53.416+02	2026-06-30 23:57:55.478+02	2026-06-30 23:57:55.478+02
casm_01KWD8KW4MN8JCT3EZMSPGGDER	cart_01KVF21BZHAQPMVMPMJFST02K8	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-30 23:57:55.477+02	2026-06-30 23:57:57.723+02	2026-06-30 23:57:57.722+02
casm_01KWD8KYARGE2Y5963QH155B44	cart_01KVF21BZHAQPMVMPMJFST02K8	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-30 23:57:57.72+02	2026-06-30 23:57:59.657+02	2026-06-30 23:57:59.657+02
casm_01KWD8M078TZCPYVKGV19RXH24	cart_01KVF21BZHAQPMVMPMJFST02K8	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-30 23:57:59.656+02	2026-06-30 23:58:01.351+02	2026-06-30 23:58:01.351+02
casm_01KWD8M1W65D3GYWJRMAXYHVFD	cart_01KVF21BZHAQPMVMPMJFST02K8	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-30 23:58:01.35+02	2026-07-01 00:01:49.893+02	2026-07-01 00:01:49.892+02
casm_01KWD8V128Y2HX4688T28WRMFC	cart_01KVF21BZHAQPMVMPMJFST02K8	Standart	\N	10	{"value": "10", "precision": 20}	f	so_01KTAFNNF59QWDVTRF6X6WJ9RG	{}	\N	2026-07-01 00:01:49.896+02	2026-07-01 00:01:56.601+02	2026-07-01 00:01:56.601+02
casm_01KWD8V7KPSYQECP9QAB6E5062	cart_01KVF21BZHAQPMVMPMJFST02K8	Standart	\N	10	{"value": "10", "precision": 20}	f	so_01KTAFNNF59QWDVTRF6X6WJ9RG	{}	\N	2026-07-01 00:01:56.598+02	2026-07-01 00:02:00.129+02	2026-07-01 00:02:00.129+02
casm_01KWD90YY95W1VP58K3PM00Q0G	cart_01KVF21BZHAQPMVMPMJFST02K8	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-07-01 00:05:04.329+02	2026-07-01 00:05:04.329+02	\N
casm_01KWD8VB20CQKZ01Z37YQPGEFC	cart_01KVF21BZHAQPMVMPMJFST02K8	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-07-01 00:02:00.128+02	2026-07-01 00:05:04.33+02	2026-07-01 00:05:04.33+02
casm_01KWTM3Y9705JQ38QVAV1HESPN	cart_01KWT6EQA1B67FMAWJ43XXT9MW	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-07-06 04:29:03.911+02	2026-07-06 04:29:03.911+02	\N
casm_01KXDHKY12KX4KDMWHHCHM4HC9	cart_01KXDHGKG57TMWKDAB6RT07J3C	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-07-13 12:50:56.419+02	2026-07-13 12:55:12.006+02	2026-07-13 12:55:12.005+02
casm_01KXDHVQM3MWJ6PDGVDX2PJWBH	cart_01KXDHGKG57TMWKDAB6RT07J3C	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-07-13 12:55:12.003+02	2026-07-13 14:25:08.313+02	2026-07-13 14:25:08.313+02
casm_01KZSRKBY5SQNY6GXDQG32B91V	cart_01KZSNW83S6222HZ28KHMG9EXJ	Standart	\N	10	{"value": "10", "precision": 20}	f	so_01KTAFNNF59QWDVTRF6X6WJ9RG	{}	\N	2026-08-12 03:15:14.757+02	2026-08-12 03:15:14.757+02	\N
casm_01KZSRPFZNMX8WAJJ3MJPKJ087	cart_01KZSRP068BQQP8TQNEB823ZCV	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-08-12 03:16:57.205+02	2026-08-12 03:16:57.205+02	\N
casm_01KZSRT8HET1Q0X50BT7NXM9DD	cart_01KZSRT71KMHMWX9DFAXP33T7W	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-08-12 03:19:00.655+02	2026-08-12 03:19:00.655+02	\N
casm_01KZSS4DCE062EJGX1E9M653KN	cart_01KZSS4BKPNCHBFWMGN0624ZPN	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-08-12 03:24:33.294+02	2026-08-12 03:24:33.294+02	\N
casm_01KZSS70HB9G3B0Y600FWQE1AQ	cart_01KZSS6Z30MMS0FNSH6K4H7HKY	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-08-12 03:25:58.444+02	2026-08-12 03:25:58.444+02	\N
casm_01KZTFBQ59Y0NR5A73HY9RZ6DC	cart_01KZTFBNRPB6DYYAKDVDE4TQPB	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-08-12 09:53:01.354+02	2026-08-12 09:53:01.354+02	\N
casm_01KZV5X7RC1BA51BAGPS2J17BR	cart_01KVAGCKDTWERGJ7WG6JW897EZ	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-08-12 16:27:04.076+02	2026-08-13 22:59:08.606+02	2026-08-13 22:59:08.605+02
casm_01KXDQ0DEP28C19GNMZ9R4YG0E	cart_01KXDHGKG57TMWKDAB6RT07J3C	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-07-13 14:25:08.31+02	2026-08-15 18:53:39.667+02	2026-08-15 18:53:39.666+02
casm_01KVB5YZT32NFZ66C5TD4DPT0X	cart_01KVAGCKDTWERGJ7WG6JW897EZ	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-06-17 18:17:23.268+02	2026-08-12 16:27:04.079+02	2026-08-12 16:27:04.078+02
casm_01KZYEY1NCBVZZ3NP2XPCMQ2PF	cart_01KVAGCKDTWERGJ7WG6JW897EZ	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-08-13 23:02:31.084+02	2026-08-13 23:02:31.084+02	\N
casm_01KZYEQVXVYV007ZH7TETNNC9C	cart_01KVAGCKDTWERGJ7WG6JW897EZ	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-08-13 22:59:08.603+02	2026-08-13 23:02:31.087+02	2026-08-13 23:02:31.086+02
casm_01M035FT6GA2K03TVCDZX8SHDF	cart_01KXDHGKG57TMWKDAB6RT07J3C	Standart	\N	10	{"value": "10", "precision": 20}	f	so_01KTAFNNF59QWDVTRF6X6WJ9RG	{}	\N	2026-08-15 18:53:39.664+02	2026-08-15 18:53:39.664+02	\N
\.


--
-- Data for Name: cart_shipping_method_adjustment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart_shipping_method_adjustment (id, description, promotion_id, code, amount, raw_amount, provider_id, metadata, created_at, updated_at, deleted_at, shipping_method_id) FROM stdin;
\.


--
-- Data for Name: cart_shipping_method_tax_line; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart_shipping_method_tax_line (id, description, tax_rate_id, code, rate, provider_id, metadata, created_at, updated_at, deleted_at, shipping_method_id) FROM stdin;
\.


--
-- Data for Name: conversation; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.conversation (id, customer_id, vendor_id, last_message_at, created_at, updated_at, deleted_at, type) FROM stdin;
01KSVVRRD4M51QGFJ12RKZN3V3	cus_01KSVPWBFY9T5MZXK47CYD788Q	01KSCS6FH5H9J6QY6ZPJ0110W5	2026-06-01 03:35:51.974+02	2026-05-30 09:14:55.013+02	2026-06-01 03:35:51.977+02	\N	direct
01KSZCADYC4Z7KN64BXJ5023R1	cus_01KSVPWBFY9T5MZXK47CYD788Q	01KSDE9JVTNAXE0NF67DNVEWBS	2026-06-01 03:36:30.623+02	2026-05-31 18:01:54.636+02	2026-06-01 03:36:30.625+02	\N	direct
01KSDJSH13J278RNCTA18TBV4D	cus_01KSDGQE4N7DEJ0C3Q810Y8CYP	01KSDE9JVTNAXE0NF67DNVEWBS	2026-05-31 14:52:21.935+02	2026-05-24 20:08:40.996+02	2026-05-31 14:52:21.939+02	\N	direct
01KXDQ4GTAETVXV2AP0ZAY2PXH	cus_01KSR173ECD4A2AJF6H3R1H2J8	01KWSMG9MENSKS30A5SCWX8JW2	\N	2026-07-13 14:27:22.826+02	2026-07-13 14:27:22.826+02	\N	direct
01KZ3JKYSD7702FT7NW3A4M6QP	cus_01KVDNF9NVQVFFF9WFB56HN13V	01KV5CHYWYZVSNYGB0RXEYG5CK	\N	2026-08-03 12:27:25.102+02	2026-08-03 12:27:25.102+02	\N	direct
01KZV2ZWAK8N40T8X1QC3BDDGA	cus_01KZV2PTYGTZ4E2VCQ7R28NYVF	01KV5CHYWYZVSNYGB0RXEYG5CK	\N	2026-08-12 15:36:04.947+02	2026-08-12 15:36:04.947+02	\N	direct
01KSZBM4SAZPVEQAZMQZFZ5NXG	cus_01KSWS7V39C4SDB1YTY9K83SMS	01KSDE9JVTNAXE0NF67DNVEWBS	2026-05-31 17:51:31.421+02	2026-05-31 17:49:44.362+02	2026-05-31 17:51:31.424+02	\N	direct
01KSRC31WGAE8QWZC9PM6RMS3Y	cus_01KSR173ECD4A2AJF6H3R1H2J8	01KSCSTSP7N25SPSF2H5AK45FY	2026-08-15 11:11:17.55+02	2026-05-29 00:43:11.888+02	2026-08-15 11:11:17.553+02	\N	direct
01KSS6HXREC788SEGBT87XV77M	cus_01KSR173ECD4A2AJF6H3R1H2J8	01KSDE9JVTNAXE0NF67DNVEWBS	2026-08-15 11:37:15.643+02	2026-05-29 08:25:42.158+02	2026-08-15 11:37:15.647+02	\N	direct
01KVAQ8F8QB8M9CP6908W8S37S	cus_01KSR173ECD4A2AJF6H3R1H2J8	01KV5CHYWYZVSNYGB0RXEYG5CK	2026-08-15 11:39:28.314+02	2026-06-17 14:00:25.367+02	2026-08-15 11:39:28.319+02	\N	direct
\.


--
-- Data for Name: credit_line; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.credit_line (id, cart_id, reference, reference_id, amount, raw_amount, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: currency; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.currency (code, symbol, symbol_native, decimal_digits, rounding, raw_rounding, name, created_at, updated_at, deleted_at) FROM stdin;
usd	$	$	2	0	{"value": "0", "precision": 20}	US Dollar	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
cad	CA$	$	2	0	{"value": "0", "precision": 20}	Canadian Dollar	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
eur	€	€	2	0	{"value": "0", "precision": 20}	Euro	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
aed	AED	د.إ.‏	2	0	{"value": "0", "precision": 20}	United Arab Emirates Dirham	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
afn	Af	؋	0	0	{"value": "0", "precision": 20}	Afghan Afghani	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
all	ALL	Lek	0	0	{"value": "0", "precision": 20}	Albanian Lek	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
amd	AMD	դր.	0	0	{"value": "0", "precision": 20}	Armenian Dram	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
ars	AR$	$	2	0	{"value": "0", "precision": 20}	Argentine Peso	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
aud	AU$	$	2	0	{"value": "0", "precision": 20}	Australian Dollar	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
azn	man.	ман.	2	0	{"value": "0", "precision": 20}	Azerbaijani Manat	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
bam	KM	KM	2	0	{"value": "0", "precision": 20}	Bosnia-Herzegovina Convertible Mark	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
bdt	Tk	৳	2	0	{"value": "0", "precision": 20}	Bangladeshi Taka	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
bgn	BGN	лв.	2	0	{"value": "0", "precision": 20}	Bulgarian Lev	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
bhd	BD	د.ب.‏	3	0	{"value": "0", "precision": 20}	Bahraini Dinar	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
bif	FBu	FBu	0	0	{"value": "0", "precision": 20}	Burundian Franc	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
bnd	BN$	$	2	0	{"value": "0", "precision": 20}	Brunei Dollar	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
bob	Bs	Bs	2	0	{"value": "0", "precision": 20}	Bolivian Boliviano	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
brl	R$	R$	2	0	{"value": "0", "precision": 20}	Brazilian Real	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
bwp	BWP	P	2	0	{"value": "0", "precision": 20}	Botswanan Pula	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
byn	Br	руб.	2	0	{"value": "0", "precision": 20}	Belarusian Ruble	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
bzd	BZ$	$	2	0	{"value": "0", "precision": 20}	Belize Dollar	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
cdf	CDF	FrCD	2	0	{"value": "0", "precision": 20}	Congolese Franc	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
chf	CHF	CHF	2	0.05	{"value": "0.05", "precision": 20}	Swiss Franc	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
clp	CL$	$	0	0	{"value": "0", "precision": 20}	Chilean Peso	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
cny	CN¥	CN¥	2	0	{"value": "0", "precision": 20}	Chinese Yuan	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
cop	CO$	$	0	0	{"value": "0", "precision": 20}	Colombian Peso	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
crc	₡	₡	0	0	{"value": "0", "precision": 20}	Costa Rican Colón	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
cve	CV$	CV$	2	0	{"value": "0", "precision": 20}	Cape Verdean Escudo	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
czk	Kč	Kč	2	0	{"value": "0", "precision": 20}	Czech Republic Koruna	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
djf	Fdj	Fdj	0	0	{"value": "0", "precision": 20}	Djiboutian Franc	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
dkk	Dkr	kr	2	0	{"value": "0", "precision": 20}	Danish Krone	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
dop	RD$	RD$	2	0	{"value": "0", "precision": 20}	Dominican Peso	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
dzd	DA	د.ج.‏	2	0	{"value": "0", "precision": 20}	Algerian Dinar	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
eek	Ekr	kr	2	0	{"value": "0", "precision": 20}	Estonian Kroon	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
egp	EGP	ج.م.‏	2	0	{"value": "0", "precision": 20}	Egyptian Pound	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
ern	Nfk	Nfk	2	0	{"value": "0", "precision": 20}	Eritrean Nakfa	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
etb	Br	Br	2	0	{"value": "0", "precision": 20}	Ethiopian Birr	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
gbp	£	£	2	0	{"value": "0", "precision": 20}	British Pound Sterling	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
gel	GEL	GEL	2	0	{"value": "0", "precision": 20}	Georgian Lari	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
ghs	GH₵	GH₵	2	0	{"value": "0", "precision": 20}	Ghanaian Cedi	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
gnf	FG	FG	0	0	{"value": "0", "precision": 20}	Guinean Franc	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
gtq	GTQ	Q	2	0	{"value": "0", "precision": 20}	Guatemalan Quetzal	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
hkd	HK$	$	2	0	{"value": "0", "precision": 20}	Hong Kong Dollar	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
hnl	HNL	L	2	0	{"value": "0", "precision": 20}	Honduran Lempira	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
hrk	kn	kn	2	0	{"value": "0", "precision": 20}	Croatian Kuna	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
huf	Ft	Ft	0	0	{"value": "0", "precision": 20}	Hungarian Forint	2026-05-24 12:23:06.712+02	2026-05-24 12:23:06.712+02	\N
idr	Rp	Rp	0	0	{"value": "0", "precision": 20}	Indonesian Rupiah	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
ils	₪	₪	2	0	{"value": "0", "precision": 20}	Israeli New Sheqel	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
inr	Rs	₹	2	0	{"value": "0", "precision": 20}	Indian Rupee	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
iqd	IQD	د.ع.‏	0	0	{"value": "0", "precision": 20}	Iraqi Dinar	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
irr	IRR	﷼	0	0	{"value": "0", "precision": 20}	Iranian Rial	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
isk	Ikr	kr	0	0	{"value": "0", "precision": 20}	Icelandic Króna	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
jmd	J$	$	2	0	{"value": "0", "precision": 20}	Jamaican Dollar	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
jod	JD	د.أ.‏	3	0	{"value": "0", "precision": 20}	Jordanian Dinar	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
jpy	¥	￥	0	0	{"value": "0", "precision": 20}	Japanese Yen	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
kes	Ksh	Ksh	2	0	{"value": "0", "precision": 20}	Kenyan Shilling	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
khr	KHR	៛	2	0	{"value": "0", "precision": 20}	Cambodian Riel	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
kmf	CF	FC	0	0	{"value": "0", "precision": 20}	Comorian Franc	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
krw	₩	₩	0	0	{"value": "0", "precision": 20}	South Korean Won	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
kwd	KD	د.ك.‏	3	0	{"value": "0", "precision": 20}	Kuwaiti Dinar	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
kzt	KZT	тңг.	2	0	{"value": "0", "precision": 20}	Kazakhstani Tenge	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
lbp	LB£	ل.ل.‏	0	0	{"value": "0", "precision": 20}	Lebanese Pound	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
lkr	SLRs	SL Re	2	0	{"value": "0", "precision": 20}	Sri Lankan Rupee	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
ltl	Lt	Lt	2	0	{"value": "0", "precision": 20}	Lithuanian Litas	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
lvl	Ls	Ls	2	0	{"value": "0", "precision": 20}	Latvian Lats	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
lyd	LD	د.ل.‏	3	0	{"value": "0", "precision": 20}	Libyan Dinar	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
mad	MAD	د.م.‏	2	0	{"value": "0", "precision": 20}	Moroccan Dirham	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
mdl	MDL	MDL	2	0	{"value": "0", "precision": 20}	Moldovan Leu	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
mga	MGA	MGA	0	0	{"value": "0", "precision": 20}	Malagasy Ariary	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
mkd	MKD	MKD	2	0	{"value": "0", "precision": 20}	Macedonian Denar	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
mmk	MMK	K	0	0	{"value": "0", "precision": 20}	Myanma Kyat	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
mnt	MNT	₮	0	0	{"value": "0", "precision": 20}	Mongolian Tugrig	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
mop	MOP$	MOP$	2	0	{"value": "0", "precision": 20}	Macanese Pataca	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
mur	MURs	MURs	0	0	{"value": "0", "precision": 20}	Mauritian Rupee	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
mwk	K	K	2	0	{"value": "0", "precision": 20}	Malawian Kwacha	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
mxn	MX$	$	2	0	{"value": "0", "precision": 20}	Mexican Peso	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
myr	RM	RM	2	0	{"value": "0", "precision": 20}	Malaysian Ringgit	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
mzn	MTn	MTn	2	0	{"value": "0", "precision": 20}	Mozambican Metical	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
nad	N$	N$	2	0	{"value": "0", "precision": 20}	Namibian Dollar	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
ngn	₦	₦	2	0	{"value": "0", "precision": 20}	Nigerian Naira	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
nio	C$	C$	2	0	{"value": "0", "precision": 20}	Nicaraguan Córdoba	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
nok	Nkr	kr	2	0	{"value": "0", "precision": 20}	Norwegian Krone	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
npr	NPRs	नेरू	2	0	{"value": "0", "precision": 20}	Nepalese Rupee	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
nzd	NZ$	$	2	0	{"value": "0", "precision": 20}	New Zealand Dollar	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
omr	OMR	ر.ع.‏	3	0	{"value": "0", "precision": 20}	Omani Rial	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
pab	B/.	B/.	2	0	{"value": "0", "precision": 20}	Panamanian Balboa	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
pen	S/.	S/.	2	0	{"value": "0", "precision": 20}	Peruvian Nuevo Sol	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
php	₱	₱	2	0	{"value": "0", "precision": 20}	Philippine Peso	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
pkr	PKRs	₨	0	0	{"value": "0", "precision": 20}	Pakistani Rupee	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
pln	zł	zł	2	0	{"value": "0", "precision": 20}	Polish Zloty	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
pyg	₲	₲	0	0	{"value": "0", "precision": 20}	Paraguayan Guarani	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
qar	QR	ر.ق.‏	2	0	{"value": "0", "precision": 20}	Qatari Rial	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
ron	RON	RON	2	0	{"value": "0", "precision": 20}	Romanian Leu	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
rsd	din.	дин.	0	0	{"value": "0", "precision": 20}	Serbian Dinar	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
rub	RUB	₽.	2	0	{"value": "0", "precision": 20}	Russian Ruble	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
rwf	RWF	FR	0	0	{"value": "0", "precision": 20}	Rwandan Franc	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
sar	SR	ر.س.‏	2	0	{"value": "0", "precision": 20}	Saudi Riyal	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
sdg	SDG	SDG	2	0	{"value": "0", "precision": 20}	Sudanese Pound	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
sek	Skr	kr	2	0	{"value": "0", "precision": 20}	Swedish Krona	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
sgd	S$	$	2	0	{"value": "0", "precision": 20}	Singapore Dollar	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
sos	Ssh	Ssh	0	0	{"value": "0", "precision": 20}	Somali Shilling	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
syp	SY£	ل.س.‏	0	0	{"value": "0", "precision": 20}	Syrian Pound	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
thb	฿	฿	2	0	{"value": "0", "precision": 20}	Thai Baht	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
tnd	DT	د.ت.‏	3	0	{"value": "0", "precision": 20}	Tunisian Dinar	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
top	T$	T$	2	0	{"value": "0", "precision": 20}	Tongan Paʻanga	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
tjs	TJS	с.	2	0	{"value": "0", "precision": 20}	Tajikistani Somoni	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
try	₺	₺	2	0	{"value": "0", "precision": 20}	Turkish Lira	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
ttd	TT$	$	2	0	{"value": "0", "precision": 20}	Trinidad and Tobago Dollar	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
twd	NT$	NT$	2	0	{"value": "0", "precision": 20}	New Taiwan Dollar	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
tzs	TSh	TSh	0	0	{"value": "0", "precision": 20}	Tanzanian Shilling	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
uah	₴	₴	2	0	{"value": "0", "precision": 20}	Ukrainian Hryvnia	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
ugx	USh	USh	0	0	{"value": "0", "precision": 20}	Ugandan Shilling	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
uyu	$U	$	2	0	{"value": "0", "precision": 20}	Uruguayan Peso	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
uzs	UZS	UZS	0	0	{"value": "0", "precision": 20}	Uzbekistan Som	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
vef	Bs.F.	Bs.F.	2	0	{"value": "0", "precision": 20}	Venezuelan Bolívar	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
vnd	₫	₫	0	0	{"value": "0", "precision": 20}	Vietnamese Dong	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
xaf	FCFA	FCFA	0	0	{"value": "0", "precision": 20}	CFA Franc BEAC	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
xof	CFA	CFA	0	0	{"value": "0", "precision": 20}	CFA Franc BCEAO	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
xpf	₣	₣	0	0	{"value": "0", "precision": 20}	CFP Franc	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
yer	YR	ر.ي.‏	0	0	{"value": "0", "precision": 20}	Yemeni Rial	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
zar	R	R	2	0	{"value": "0", "precision": 20}	South African Rand	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
zmk	ZK	ZK	0	0	{"value": "0", "precision": 20}	Zambian Kwacha	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
zwl	ZWL$	ZWL$	0	0	{"value": "0", "precision": 20}	Zimbabwean Dollar	2026-05-24 12:23:06.713+02	2026-05-24 12:23:06.713+02	\N
\.


--
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customer (id, company_name, first_name, last_name, email, phone, has_account, metadata, created_at, updated_at, deleted_at, created_by) FROM stdin;
cus_01KSDGQE4N7DEJ0C3Q810Y8CYP	\N	prince	lulinda	princelulinda+890@gmail.com	66852137	t	\N	2026-05-24 19:32:35.35+02	2026-05-24 19:32:35.35+02	\N	\N
cus_01KSQWM10KJ2G0R75KZJYHDB6H	\N	Prince	lulinda	princelulinda78@gmail.com	666666777	t	\N	2026-05-28 20:12:50.835+02	2026-05-28 20:12:50.835+02	\N	\N
cus_01KSVPWBFY9T5MZXK47CYD788Q	\N	prince	-	princelulinda10@gmail.com	888888	t	\N	2026-05-30 07:49:29.982+02	2026-05-30 07:49:29.982+02	\N	\N
cus_01KSWS7V39C4SDB1YTY9K83SMS	\N	prince	crespo	princelulinda11@gmail.com	33666	t	\N	2026-05-30 17:49:57.993+02	2026-05-30 17:49:57.993+02	\N	\N
cus_01KVDNF9NVQVFFF9WFB56HN13V	\N	\N	\N	princelulinda@gmail.com	\N	f	\N	2026-06-18 17:26:55.163+02	2026-06-18 17:26:55.163+02	\N	\N
cus_01KWTHT7FNHAP08HMCSJ9NW4P9	\N	Melance	Nzohabonwanayo	melancenzohabonwanayo@gmail.com	\N	f	\N	2026-07-06 03:48:48.502+02	2026-07-06 03:48:48.502+02	\N	\N
cus_01KWTJAF28STSEK2811R1QW1ZW	\N	Prince	Crespo	princelulinda562@gmail.com	\N	t	\N	2026-07-06 03:57:40.552+02	2026-07-06 03:57:40.552+02	\N	\N
cus_01KWTJDVCJA6KHS6TX3DTG1P1K	\N	Crespo	probably	princelulinda3200@gmail.com	67887152	t	\N	2026-07-06 03:59:31.474+02	2026-07-06 03:59:31.474+02	\N	\N
cus_01KSR173ECD4A2AJF6H3R1H2J8	\N	prince	lulindagg	princelulinda32@gmail.com	76777777	t	\N	2026-05-28 21:33:10.221+02	2026-07-06 19:30:59.6+02	\N	\N
cus_01KWXQ71ESXH4GETPYWRYMRFJK	\N	ygo		ygo.solution@gmail.com	\N	f	\N	2026-07-07 09:20:54.493+02	2026-07-07 09:20:54.493+02	\N	\N
cus_01KWXQCXR7D8SR1DYEGETXBERC	\N	Lulinda	Prince	princelulinda12@gmail.com	\N	f	\N	2026-07-07 09:24:07.303+02	2026-07-07 09:24:07.303+02	\N	\N
cus_01KZSMAT6WFYWBGMFDGBSQVMKG	\N	Loyalty	Test	loyaltytest_1786492840@example.com	\N	t	\N	2026-08-12 02:00:40.157+02	2026-08-12 02:00:40.157+02	\N	\N
cus_01KZSMBZ99Z0Q8P5KTCWCBMJ73	\N	Spin	Test1	loyaltyspin_1786492878_1@example.com	\N	t	\N	2026-08-12 02:01:18.121+02	2026-08-12 02:01:18.121+02	\N	\N
cus_01KZSMBZHQEP9A4XJX4MPZBXC4	\N	Spin	Test2	loyaltyspin_1786492878_2@example.com	\N	t	\N	2026-08-12 02:01:18.391+02	2026-08-12 02:01:18.391+02	\N	\N
cus_01KZSMBZSJPHZ5M70N0KP35E5G	\N	Spin	Test3	loyaltyspin_1786492878_3@example.com	\N	t	\N	2026-08-12 02:01:18.642+02	2026-08-12 02:01:18.642+02	\N	\N
cus_01KZSMC01DK743K662A96FWK8D	\N	Spin	Test4	loyaltyspin_1786492878_4@example.com	\N	t	\N	2026-08-12 02:01:18.893+02	2026-08-12 02:01:18.893+02	\N	\N
cus_01KZSMC096Y09WY697T3056N0G	\N	Spin	Test5	loyaltyspin_1786492879_5@example.com	\N	t	\N	2026-08-12 02:01:19.142+02	2026-08-12 02:01:19.142+02	\N	\N
cus_01KZSMC0H1D16FKPAF1RH2CT27	\N	Spin	Test6	loyaltyspin_1786492879_6@example.com	\N	t	\N	2026-08-12 02:01:19.393+02	2026-08-12 02:01:19.393+02	\N	\N
cus_01KZSMC0SBE2M7VR1R9XBKMQFY	\N	Spin	Test7	loyaltyspin_1786492879_7@example.com	\N	t	\N	2026-08-12 02:01:19.659+02	2026-08-12 02:01:19.659+02	\N	\N
cus_01KZSMC11E5Y9F9SDEM99VXJPS	\N	Spin	Test8	loyaltyspin_1786492879_8@example.com	\N	t	\N	2026-08-12 02:01:19.919+02	2026-08-12 02:01:19.919+02	\N	\N
cus_01KZSMC195G8H5AHKKYE09VZX2	\N	Spin	Test9	loyaltyspin_1786492880_9@example.com	\N	t	\N	2026-08-12 02:01:20.165+02	2026-08-12 02:01:20.165+02	\N	\N
cus_01KZSMC1GNSS9SXPZ2ZX39N7J9	\N	Spin	Test10	loyaltyspin_1786492880_10@example.com	\N	t	\N	2026-08-12 02:01:20.405+02	2026-08-12 02:01:20.405+02	\N	\N
cus_01KZSMC1S8PAS0DKWVYD1TNNPM	\N	Spin	Test11	loyaltyspin_1786492880_11@example.com	\N	t	\N	2026-08-12 02:01:20.681+02	2026-08-12 02:01:20.681+02	\N	\N
cus_01KZSMC22GW2AVN7D38GNN414A	\N	Spin	Test12	loyaltyspin_1786492880_12@example.com	\N	t	\N	2026-08-12 02:01:20.976+02	2026-08-12 02:01:20.976+02	\N	\N
cus_01KZSMEXNKDNW2N4PS3SQCG84M	\N	Spin2	Test1	loyaltyspin2_1786492974_1@example.com	\N	t	\N	2026-08-12 02:02:54.772+02	2026-08-12 02:02:54.772+02	\N	\N
cus_01KZSMEY0DNJ1VVM2P3S3T3222	\N	Spin2	Test2	loyaltyspin2_1786492974_2@example.com	\N	t	\N	2026-08-12 02:02:55.117+02	2026-08-12 02:02:55.117+02	\N	\N
cus_01KZSRK3GY7H9W4XQEVRX7V4ZX	\N	\N	\N	socialprooftest@example.com	\N	f	\N	2026-08-12 03:15:06.142+02	2026-08-12 03:15:06.142+02	\N	\N
cus_01KZSRPF04TZB7SAT86MV8YP2J	\N	\N	\N	socialprooftest2@example.com	\N	f	\N	2026-08-12 03:16:56.197+02	2026-08-12 03:16:56.197+02	\N	\N
cus_01KZSRT7Q29W9N12GXQK6SVY8E	\N	\N	\N	debugtest@example.com	\N	f	\N	2026-08-12 03:18:59.811+02	2026-08-12 03:18:59.811+02	\N	\N
cus_01KZSS4CJSGT6HDXZ310W1C82K	\N	\N	\N	debugtest3@example.com	\N	f	\N	2026-08-12 03:24:32.473+02	2026-08-12 03:24:32.473+02	\N	\N
cus_01KZSS6ZQW5RQBDPWQCEDQ0BVR	\N	\N	\N	debugtest4@example.com	\N	f	\N	2026-08-12 03:25:57.628+02	2026-08-12 03:25:57.628+02	\N	\N
cus_01KZTETSA89TK03RE3G06BXQDJ	\N	prince	lulinda	princelulinda320@gmail.com	\N	t	\N	2026-08-12 09:43:46.505+02	2026-08-12 09:43:46.505+02	\N	\N
cus_01KZTFASX63451FWPYQZST4A8M	\N	Referred	Test	referraltest_1786521151@example.com	\N	t	\N	2026-08-12 09:52:31.399+02	2026-08-12 09:52:31.399+02	\N	\N
cus_01KZV2PTYGTZ4E2VCQ7R28NYVF	\N	Prince	lulinda	princelulinda+2@gmail.com	\N	t	\N	2026-08-12 15:31:08.625+02	2026-08-12 15:31:08.625+02	\N	\N
cus_01M0196WGTMRHZWT20K8ZDQ9ZF	\N	crespo	-	princelulinda+78@gmail.com	\N	t	\N	2026-08-15 01:20:12.571+02	2026-08-15 01:20:12.571+02	\N	\N
cus_01M019BGZDAKS45SQB3VRG2PW5	\N	jule	de personnes	princelulinda+11@gmail.com	\N	t	\N	2026-08-15 01:22:44.589+02	2026-08-15 01:22:44.589+02	\N	\N
cus_01M019M1H41EYR3ETMFFPDJNQA	\N	île	déserte	princelulinda+76@gmail.com	\N	t	\N	2026-08-15 01:27:23.684+02	2026-08-15 01:27:23.684+02	\N	\N
cus_01M01ABZNY6SPV79YG95TRCN89	\N	princelulinda+13@gmail.com	-	princelulinda+13@gmail.com	\N	t	{"email_verified": false, "verification_code_hash": "eb100934fbc09a2627aa31d5644d600fa6e57b77bc582ec0ac94efc400bed7ef", "verification_last_sent_at": "2026-08-14T23:40:32.366Z", "verification_code_expires_at": "2026-08-14T23:55:32.366Z"}	2026-08-15 01:40:28.222+02	2026-08-15 01:40:32.369+02	\N	\N
cus_01M01C3WQD8YCZYFB1B6QQE5AE	\N	Prince	lulinda	princelulinda+87@gmail.com	\N	t	{"email_verified": true}	2026-08-15 02:11:00.206+02	2026-08-15 02:11:04.459+02	\N	\N
cus_01M01D4FZGTRMJ99SJJ3WWS4B8	\N	Prince	lulinda	princelulinda+888@gmail.com	\N	t	{"email_verified": true}	2026-08-15 02:28:48.497+02	2026-08-15 02:28:52.919+02	\N	\N
\.


--
-- Data for Name: customer_account_holder; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customer_account_holder (customer_id, account_holder_id, id, created_at, updated_at, deleted_at) FROM stdin;
cus_01KSVPWBFY9T5MZXK47CYD788Q	acchld_01KSWZ94HFGMXS8Z8D3YATDQRX	custacchldr_01KSWZ94HTMZRVD1HBXDVN2RJ9	2026-05-30 19:35:31.897545+02	2026-05-30 19:35:31.897545+02	\N
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KSYNR3BVMPX2V3KKBG485GEQ	custacchldr_01KSYNR3C2GZ1HP01CB14MWV43	2026-05-31 11:27:25.313965+02	2026-05-31 11:27:25.313965+02	\N
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT72K27VMV7810029CKFA2H1	custacchldr_01KT72K28GRBMDQNFNCT1DCT47	2026-06-03 17:45:47.279509+02	2026-06-03 17:45:47.693+02	2026-06-03 17:45:47.691+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT72ZRCVH4VVBVQFJHAPYG00	custacchldr_01KT72ZRDHV621ZB8E00C5GXR7	2026-06-03 17:52:43.184263+02	2026-06-03 17:52:44.185+02	2026-06-03 17:52:44.184+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT72ZX16H8EFA9985M78JZ2C	custacchldr_01KT72ZX1MYN6639NCTY5YYH8X	2026-06-03 17:52:47.923651+02	2026-06-03 17:52:48.351+02	2026-06-03 17:52:48.35+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT730228ZS2Q13C80NB2CB55	custacchldr_01KT73022MKXPH6AG3MCTW2HZ0	2026-06-03 17:52:53.076045+02	2026-06-03 17:52:53.997+02	2026-06-03 17:52:53.997+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT7313DRM3KQX8S9F5CG6XGY	custacchldr_01KT7313E7DG3BCKHSC8BP4XCE	2026-06-03 17:53:27.239041+02	2026-06-03 17:53:28.082+02	2026-06-03 17:53:28.081+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT740PMW9GF51S77Z9CBZ7EV	custacchldr_01KT740PN3MK7NN69TR9NBH16V	2026-06-03 18:10:42.723024+02	2026-06-03 18:10:43.592+02	2026-06-03 18:10:43.591+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT7419J1RYAGRH5QDZD58EB4	custacchldr_01KT7419JAB1TE7PR3DEA89WKX	2026-06-03 18:11:02.089374+02	2026-06-03 18:11:03.051+02	2026-06-03 18:11:03.051+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT743222GXD44PTTF7P90P5T	custacchldr_01KT743227KE9P5QR7B9SXZ7XB	2026-06-03 18:11:59.942971+02	2026-06-03 18:12:00.807+02	2026-06-03 18:12:00.807+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT744P2JYKGWX26TNF9KA0DQ	custacchldr_01KT744P2TTW08RC6WS8JE5J9M	2026-06-03 18:12:53.210143+02	2026-06-03 18:12:53.993+02	2026-06-03 18:12:53.992+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT77YSF8NV1RBKA2B0MJW9DY	custacchldr_01KT77YSFHP2SB12J8X4N43NV3	2026-06-03 19:19:34.385024+02	2026-06-03 19:19:39.387+02	2026-06-03 19:19:39.387+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT7853DZQBRACRN4SWVCQ8M9	custacchldr_01KT7853EAHARRH7T8T8YSC5RC	2026-06-03 19:23:01.193525+02	2026-06-03 19:23:02.956+02	2026-06-03 19:23:02.955+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT786NPZSGR6D0PMS10A2XM1	custacchldr_01KT786NQMWCEW35RWCHKDEN77	2026-06-03 19:23:52.691754+02	2026-06-03 19:23:56.916+02	2026-06-03 19:23:56.915+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT78APHMMEXR8VYTEH0N6XE7	custacchldr_01KT78APJ3BXFJDDGV5HD5K3EC	2026-06-03 19:26:04.610938+02	2026-06-03 19:26:07.033+02	2026-06-03 19:26:07.032+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT78JGXDKHNPV6J14QZYWFWE	custacchldr_01KT78JGY2Q4C9S00X2981Y03K	2026-06-03 19:30:20.994227+02	2026-06-03 19:30:26.688+02	2026-06-03 19:30:26.687+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT78QQPX2S80BBEWX16HB7EF	custacchldr_01KT78QQQ8F3YMNYPSQBD19W04	2026-06-03 19:33:11.78424+02	2026-06-03 19:33:22.325+02	2026-06-03 19:33:22.325+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT78RQKZZ6W6KAE0Y3Q12CFJ	custacchldr_01KT78RQMCPZJNPQE4XHVKCCRX	2026-06-03 19:33:44.459615+02	2026-06-03 19:33:54.989+02	2026-06-03 19:33:54.988+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT78TP6KKZM8KYS4K4G2HN2Y	custacchldr_01KT78TP6ZZ31Q77W6RP7GVQDZ	2026-06-03 19:34:48.542388+02	2026-06-03 19:34:50.806+02	2026-06-03 19:34:50.805+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT78YJHQ5QRWEP50R0P98RYP	custacchldr_01KT78YJJ2X9SAJ5G6XWE3NG7F	2026-06-03 19:36:55.872968+02	2026-06-03 19:36:57.195+02	2026-06-03 19:36:57.195+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT792R7YSQX7MYV9VPYP35B7	custacchldr_01KT792R8AYVBGZHZQA5HBBE80	2026-06-03 19:39:12.77806+02	2026-06-03 19:39:16.472+02	2026-06-03 19:39:16.471+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT7957JCDMHW26GYT6W5ZG58	custacchldr_01KT7957K10XNJHN03HSR6XY43	2026-06-03 19:40:34.016678+02	2026-06-03 19:40:44.551+02	2026-06-03 19:40:44.55+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT796CZV10EBXPRYDPBMTEEE	custacchldr_01KT796D03RGF665XTVFC6DQ34	2026-06-03 19:41:12.323352+02	2026-06-03 19:41:15.171+02	2026-06-03 19:41:15.171+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT7ADJ1TQ2RJXH4544BN3YZ7	custacchldr_01KT7ADJ20FPFSEFS6PT1BZD28	2026-06-03 20:02:35.456003+02	2026-06-03 20:02:39.336+02	2026-06-03 20:02:39.336+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT7APA2KTQQWJ612EKRS66W7	custacchldr_01KT7APA2R0V1WABYJSV8P678C	2026-06-03 20:07:22.200669+02	2026-06-03 20:07:33.813+02	2026-06-03 20:07:33.813+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT7AYC6YBS2TK1A79Y8TYQNA	custacchldr_01KT7AYC731QMGS8YTMAJEQGHN	2026-06-03 20:11:46.531036+02	2026-06-03 20:11:49.862+02	2026-06-03 20:11:49.861+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT7BJ1VTCR5XGHG4NNHFTKSJ	custacchldr_01KT7BJ1W2BC1FM1BBJ0EMBJAT	2026-06-03 20:22:31.297761+02	2026-06-03 20:22:32.795+02	2026-06-03 20:22:32.794+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT7BQHZ44043FC4KNSSH63FJ	custacchldr_01KT7BQHZDHABWH74KQP4XHGM4	2026-06-03 20:25:31.628425+02	2026-06-03 20:25:32.564+02	2026-06-03 20:25:32.563+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT8YR85GM34NAPW38X13D1ZJ	custacchldr_01KT8YR85SSPVNCK61JCHH15EB	2026-06-04 11:17:11.736638+02	2026-06-04 11:17:12.894+02	2026-06-04 11:17:12.894+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT8Z0Y9AXYW3GJY9QWJ7C4HX	custacchldr_01KT8Z0Y9K5H7ZNMW582ZJARR8	2026-06-04 11:21:56.530656+02	2026-06-04 11:21:59.507+02	2026-06-04 11:21:59.506+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT8ZQT3A31SKXM609FYA8WPA	custacchldr_01KT8ZQT3WGQ1EVVNXGGA3M2A0	2026-06-04 11:34:25.915807+02	2026-06-04 11:34:27.666+02	2026-06-04 11:34:27.665+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT8ZXHCMZANA7YT5V0GBH1TY	custacchldr_01KT8ZXHCW5VETSCPY4EYKAW3B	2026-06-04 11:37:33.596228+02	2026-06-04 11:37:34.635+02	2026-06-04 11:37:34.635+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT904ZDP9QDWWZM3MQ8EPDER	custacchldr_01KT904ZDYSVE792379CMS9S7T	2026-06-04 11:41:37.341841+02	2026-06-04 11:41:39.008+02	2026-06-04 11:41:39.008+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT911E2EJD10ANBR6XBZPZ1J	custacchldr_01KT911E2JYHKK723J7VVKW1YR	2026-06-04 11:57:09.842751+02	2026-06-04 11:57:10.607+02	2026-06-04 11:57:10.606+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT911K5DW3A448756PYKR97H	custacchldr_01KT911K5K17K2J0Y4XHEQ9N91	2026-06-04 11:57:15.059154+02	2026-06-04 11:57:16.006+02	2026-06-04 11:57:16.005+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT914B31VMBA59JCCWT9R46R	custacchldr_01KT914B36KSYGGV8GJQ0JXK5Y	2026-06-04 11:58:45.09439+02	2026-06-04 11:58:50.376+02	2026-06-04 11:58:50.376+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT918223STD6KBEKQFQSXN5F	custacchldr_01KT9182296DGKR6WJN7M5BZSE	2026-06-04 12:00:46.921124+02	2026-06-04 12:00:47.766+02	2026-06-04 12:00:47.766+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT91884EX9X8G33FAQ3QR5D6	custacchldr_01KT91884N9E8SX62Y6M4WR071	2026-06-04 12:00:53.141195+02	2026-06-04 12:00:53.929+02	2026-06-04 12:00:53.928+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT9454ZCWYT0XXKQJSSR7PBY	custacchldr_01KT9454ZPW4B77C10CN6DXB9F	2026-06-04 12:51:37.333321+02	2026-06-04 12:51:39.876+02	2026-06-04 12:51:39.875+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT947507M449NGQ7BTVFRX0E	custacchldr_01KT94750DCWN5DBF4MEEV62BT	2026-06-04 12:52:42.893079+02	2026-06-04 12:52:51.931+02	2026-06-04 12:52:51.93+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT94EY0FQ0EA3CTWD4W0A2ZQ	custacchldr_01KT94EY0YZJMWHT8CEY58C4SY	2026-06-04 12:56:57.885526+02	2026-06-04 12:56:58.992+02	2026-06-04 12:56:58.992+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT964WB4HA4BCEQJ9RYZHQEH	custacchldr_01KT964WBEB2MFC5TM8GM8NHBE	2026-06-04 13:26:25.645793+02	2026-06-04 13:26:27.558+02	2026-06-04 13:26:27.557+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT967RCG7GEN100DG2WRZ2KC	custacchldr_01KT967RCRTDWEKV5EQXMHZG2X	2026-06-04 13:27:59.896458+02	2026-06-04 13:28:02.195+02	2026-06-04 13:28:02.194+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT968GXX744AEB31NJYTQNSP	custacchldr_01KT968GY6VM7FZSJNYX6F956N	2026-06-04 13:28:25.029799+02	2026-06-04 13:28:26.092+02	2026-06-04 13:28:26.091+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT96CAWGJFM2RA1B1JHERMEC	custacchldr_01KT96CAWNN8JT2Z2T9K7RVJMZ	2026-06-04 13:30:29.909615+02	2026-06-04 13:30:31.062+02	2026-06-04 13:30:31.061+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT96EV7AZPCP4TS31THCVGX8	custacchldr_01KT96EV7W1YW3VM16XZPVPRVH	2026-06-04 13:31:52.188399+02	2026-06-04 13:31:56.627+02	2026-06-04 13:31:56.627+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT996ZCS3QTZE7EBVVZ3ST7F	custacchldr_01KT996ZD73YHT3FP6DZG3TE31	2026-06-04 14:20:00.038058+02	2026-06-04 14:20:01.091+02	2026-06-04 14:20:01.09+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT999FD38CHRCBCNE3358D4N	custacchldr_01KT999FDKC3R4S91Z3CZNDH3A	2026-06-04 14:21:21.970795+02	2026-06-04 14:21:22.962+02	2026-06-04 14:21:22.96+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT99ADR84495CZYD7YP8MACX	custacchldr_01KT99ADRXR4QZ82FW0ATV0DRS	2026-06-04 14:21:53.053072+02	2026-06-04 14:21:53.966+02	2026-06-04 14:21:53.964+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT99M4VY6QV2HN1AR9A1D8MV	custacchldr_01KT99M4W6TMG15KE289G9V8EE	2026-06-04 14:27:11.621352+02	2026-06-04 14:27:12.463+02	2026-06-04 14:27:12.462+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT99N1TWSAPBZG3YDRA88CGP	custacchldr_01KT99N1VDWJ1DSWDPJ2KAMN0G	2026-06-04 14:27:41.292666+02	2026-06-04 14:27:42.485+02	2026-06-04 14:27:42.484+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT9CN0SZFX8VTRF6B8X7V8YE	custacchldr_01KT9CN0TBXX4METN5FB2NBM0B	2026-06-04 15:20:05.96316+02	2026-06-04 15:20:06.988+02	2026-06-04 15:20:06.987+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT9A0D7ATR6MGJSYNSQEYTA5	custacchldr_01KT9A0D7P9KSSF78ADFT9G3J8	2026-06-04 14:33:53.398389+02	2026-06-04 14:34:03.938+02	2026-06-04 14:34:03.937+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT9CPTPVBND0XMSK9CFGCAJH	custacchldr_01KT9CPTQ1M9P2T9G9AK1M4Q3S	2026-06-04 15:21:05.24941+02	2026-06-04 15:21:05.24941+02	\N
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT9A0Z52PDD1M0GQ5CRVH181	custacchldr_01KT9A0Z5ZXVX9HME3N16HKY5P	2026-06-04 14:34:11.768181+02	2026-06-04 14:34:13.931+02	2026-06-04 14:34:13.931+02
cus_01KZTFASX63451FWPYQZST4A8M	acchld_01KZTFBQKTM9HP0RTPEARR5QAZ	custacchldr_01KZTFBQM6ZGMRJY0ATX5V255G	2026-08-12 09:53:01.829747+02	2026-08-12 09:53:01.829747+02	\N
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT9A1HQP5XRS6W9GMPECTSBB	custacchldr_01KT9A1HR2HBKYM5PCBV5QV3MQ	2026-06-04 14:34:30.785653+02	2026-06-04 14:34:33.247+02	2026-06-04 14:34:33.246+02
cus_01KZV2PTYGTZ4E2VCQ7R28NYVF	acchld_01KZV5XB1X9EASGVQNXGVHFYKJ	custacchldr_01KZV5XB2AKC9JP7JJZFDX7G9C	2026-08-12 16:27:07.465431+02	2026-08-12 16:27:07.465431+02	\N
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT9A53XZF1JNHDTAF28EJS90	custacchldr_01KT9A53YA69A4VVCVSMTA279J	2026-06-04 14:36:27.7225+02	2026-06-04 14:36:38.244+02	2026-06-04 14:36:38.244+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT9A5GZS5AMKJY16E6ZMRTMT	custacchldr_01KT9A5GZZYYXTMYNX2B4Y2DGR	2026-06-04 14:36:41.087102+02	2026-06-04 14:36:51.598+02	2026-06-04 14:36:51.598+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT9A633BG39AWZWV2RSEM58J	custacchldr_01KT9A633RFGEJP1RC3NMY4V1D	2026-06-04 14:36:59.640705+02	2026-06-04 14:37:09.28+02	2026-06-04 14:37:09.28+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT9ACRC0AFEMR8BBRGB5S56J	custacchldr_01KT9ACRCAJS63Z19ZT5731RH3	2026-06-04 14:40:38.026626+02	2026-06-04 14:40:38.918+02	2026-06-04 14:40:38.917+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT9AJ21Z3C24J2YC59BVEGPK	custacchldr_01KT9AJ227F3PE6XVMFRHNQSD8	2026-06-04 14:43:31.783679+02	2026-06-04 14:43:33.993+02	2026-06-04 14:43:33.992+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT9AMKN27F4E0DZE16T7KE2B	custacchldr_01KT9AMKNZV0ED14BV8CBKWEFP	2026-06-04 14:44:55.358998+02	2026-06-04 14:44:56.366+02	2026-06-04 14:44:56.365+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT9ANCMNAWW8B76QQ37YK093	custacchldr_01KT9ANCMV7NGPSJ2PBJT17EM9	2026-06-04 14:45:20.923369+02	2026-06-04 14:45:31.445+02	2026-06-04 14:45:31.445+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT9ANWFR00V58JCS6R7DK32W	custacchldr_01KT9ANWG0TFFMQ5T13011H93M	2026-06-04 14:45:37.151686+02	2026-06-04 14:45:47.676+02	2026-06-04 14:45:47.675+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT9APP90YTKKQFW351CQPV5N	custacchldr_01KT9APP99D1M9CDZ5W78WB5JS	2026-06-04 14:46:03.56041+02	2026-06-04 14:46:14.08+02	2026-06-04 14:46:14.08+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT9BJM7YND2DKY31R1ZPG9BW	custacchldr_01KT9BJM824510B95XJJCZMYT7	2026-06-04 15:01:18.978574+02	2026-06-04 15:01:20.49+02	2026-06-04 15:01:20.489+02
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT9CJ0XKNXPAXFA754C6SYAQ	custacchldr_01KT9CJ0XR9ZYEGVY8PNQ52E9J	2026-06-04 15:18:27.768629+02	2026-06-04 15:18:32.627+02	2026-06-04 15:18:32.626+02
\.


--
-- Data for Name: customer_address; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customer_address (id, customer_id, address_name, is_default_shipping, is_default_billing, company, first_name, last_name, address_1, address_2, city, country_code, province, postal_code, phone, metadata, created_at, updated_at, deleted_at) FROM stdin;
cuaddr_01KSQXK0WBFKYBD6AJ31JFYEYE	cus_01KSQWM10KJ2G0R75KZJYHDB6H	\N	t	t	\N	Prince	lulinda	Line	Gifugwe	Gifurwe	bi	Bubanza			\N	2026-05-28 20:29:46.507+02	2026-05-28 20:29:55.733+02	\N
cuaddr_01KSVPXDMC7X1M67T9QW4EJSHR	cus_01KSVPWBFY9T5MZXK47CYD788Q	\N	f	f	\N	prince	-	Line 1		Musenyi	bi	Bubanza			\N	2026-05-30 07:50:04.94+02	2026-05-30 07:50:04.94+02	\N
cuaddr_01KWD877YFJR761TZV35PXNGTX	cus_01KSR173ECD4A2AJF6H3R1H2J8	\N	f	f	\N	prince	lulinda	baraka	556	baraka ville	CD		555	76777777	\N	2026-06-30 23:51:01.584+02	2026-07-01 00:22:59.654+02	\N
cuaddr_01KSR1BKSFHXS9Z8FXMA530N89	cus_01KSR173ECD4A2AJF6H3R1H2J8	\N	t	f	\N	prince	lulinda	Line		Musenyi	bi	Bubanza			\N	2026-05-28 21:35:38.031+02	2026-07-01 00:22:59.663+02	\N
cuaddr_01KZV5WPYTZVAHJ1JY2XHBKXVT	cus_01KZV2PTYGTZ4E2VCQ7R28NYVF	\N	f	f	\N	Prince	lulinda	Bujumbura	Gifugwe	Gifurwe	bi	Bubanza		667881752	\N	2026-08-12 16:26:46.874+02	2026-08-12 16:26:46.874+02	\N
\.


--
-- Data for Name: customer_group; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customer_group (id, name, metadata, created_by, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: customer_group_customer; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customer_group_customer (id, customer_id, customer_group_id, metadata, created_at, updated_at, created_by, deleted_at) FROM stdin;
\.


--
-- Data for Name: customer_loyalty; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customer_loyalty (id, customer_id, points_balance, lifetime_points, tier, current_streak, longest_streak, last_checkin_date, last_wheel_spin_date, created_at, updated_at, deleted_at, referral_code) FROM stdin;
01KZTEX2KPQ3HPRRSZB4J21987	cus_01KZTETSA89TK03RE3G06BXQDJ	100	100	bronze	0	0	\N	2026-08-12	2026-08-12 09:45:01.558+02	2026-08-12 09:47:22.694+02	\N	\N
01KZSKVSMN35D0B5K3Y3Y8VYNG	cus_01KWTJDVCJA6KHS6TX3DTG1P1K	12	12	bronze	1	1	2026-08-12	\N	2026-08-12 01:52:28.054+02	2026-08-12 01:53:34.096+02	\N	\N
01KZSMB2RF3BMZMHR0S0R0SJ6K	cus_01KZSMAT6WFYWBGMFDGBSQVMKG	62	62	bronze	1	1	2026-08-12	2026-08-12	2026-08-12 02:00:48.911+02	2026-08-12 09:49:54.278+02	\N	EM1IGXG
01KZTFC6BSCJC51YRNV4BJXT6N	cus_01KZTFASX63451FWPYQZST4A8M	0	0	bronze	0	0	\N	\N	2026-08-12 09:53:16.922+02	2026-08-12 09:53:16.933+02	\N	EMYMFPY
01KZSMBZD4H1C9STH238FXZRAB	cus_01KZSMBZ99Z0Q8P5KTCWCBMJ73	20	20	bronze	0	0	\N	2026-08-12	2026-08-12 02:01:18.244+02	2026-08-12 02:01:18.258+02	\N	\N
01KZSMBZNBJFHRKXF7V72Q9NMA	cus_01KZSMBZHQEP9A4XJX4MPZBXC4	50	50	bronze	0	0	\N	2026-08-12	2026-08-12 02:01:18.508+02	2026-08-12 02:01:18.519+02	\N	\N
01KZV2R16R60TMY8APYCMJFQS3	cus_01KZV2PTYGTZ4E2VCQ7R28NYVF	20	20	bronze	0	0	\N	2026-08-12	2026-08-12 15:31:47.8+02	2026-08-12 15:32:29.313+02	\N	\N
01KZSMBZXAVZ40471N9B5ADJ5Q	cus_01KZSMBZSJPHZ5M70N0KP35E5G	20	20	bronze	0	0	\N	2026-08-12	2026-08-12 02:01:18.762+02	2026-08-12 02:01:18.771+02	\N	\N
01KZSMC053G1K8N298J950H9W8	cus_01KZSMC01DK743K662A96FWK8D	0	0	bronze	0	0	\N	2026-08-12	2026-08-12 02:01:19.011+02	2026-08-12 02:01:19.017+02	\N	\N
01KZSMC0CWH0MBAEPZ6WBW7WYS	cus_01KZSMC096Y09WY697T3056N0G	50	50	bronze	0	0	\N	2026-08-12	2026-08-12 02:01:19.26+02	2026-08-12 02:01:19.268+02	\N	\N
01KZSMC0MZFK1N43XZ12952K6R	cus_01KZSMC0H1D16FKPAF1RH2CT27	20	20	bronze	0	0	\N	2026-08-12	2026-08-12 02:01:19.519+02	2026-08-12 02:01:19.533+02	\N	\N
01KZSMC0XD0KC9R865TEBQN2NS	cus_01KZSMC0SBE2M7VR1R9XBKMQFY	50	50	bronze	0	0	\N	2026-08-12	2026-08-12 02:01:19.789+02	2026-08-12 02:01:19.797+02	\N	\N
01M0192MZDR43Q5FNHXCN6RBJT	cus_01KWTHT7FNHAP08HMCSJ9NW4P9	100	100	bronze	0	0	\N	2026-08-15	2026-08-15 01:17:53.773+02	2026-08-15 02:18:22.349+02	\N	\N
01KZSMC151SK5MMQE0NPK6WQQP	cus_01KZSMC11E5Y9F9SDEM99VXJPS	100	100	bronze	0	0	\N	2026-08-12	2026-08-12 02:01:20.034+02	2026-08-12 02:01:20.043+02	\N	\N
01KZSMC1CQ31MKXNZS57BS2WVW	cus_01KZSMC195G8H5AHKKYE09VZX2	0	0	bronze	0	0	\N	2026-08-12	2026-08-12 02:01:20.279+02	2026-08-12 02:01:20.284+02	\N	\N
01KZSMC1M7PN2ST3VDMFTRZPNP	cus_01KZSMC1GNSS9SXPZ2ZX39N7J9	0	0	bronze	0	0	\N	2026-08-12	2026-08-12 02:01:20.519+02	2026-08-12 02:01:20.524+02	\N	\N
01KZSMC1Y5WX9ECK76WMCV1VA7	cus_01KZSMC1S8PAS0DKWVYD1TNNPM	0	0	bronze	0	0	\N	2026-08-12	2026-08-12 02:01:20.837+02	2026-08-12 02:01:20.844+02	\N	\N
01KZSMC263XPVH5ENACB0GAXHG	cus_01KZSMC22GW2AVN7D38GNN414A	100	100	bronze	0	0	\N	2026-08-12	2026-08-12 02:01:21.091+02	2026-08-12 02:01:21.105+02	\N	\N
01KZSMEXT5JZ5CZW5KC01CKGAD	cus_01KZSMEXNKDNW2N4PS3SQCG84M	20	20	bronze	0	0	\N	2026-08-12	2026-08-12 02:02:54.917+02	2026-08-12 02:02:54.939+02	\N	\N
01KZSMEY48FZPAN6WKC834535M	cus_01KZSMEY0DNJ1VVM2P3S3T3222	0	0	bronze	0	0	\N	2026-08-12	2026-08-12 02:02:55.24+02	2026-08-12 02:02:55.248+02	\N	\N
01M02EP57WV5EYJ9NA2ZXP9V21	cus_01KVDNF9NVQVFFF9WFB56HN13V	50	50	bronze	0	0	\N	2026-08-15	2026-08-15 12:15:10.332+02	2026-08-15 12:15:36.517+02	\N	\N
01KZSMA4A7553XA5H9TZKBH0E8	cus_01KSR173ECD4A2AJF6H3R1H2J8	24	24	bronze	1	1	2026-08-15	2026-08-15	2026-08-12 02:00:17.735+02	2026-08-15 21:21:26.011+02	\N	EM2Q0UD
\.


--
-- Data for Name: customer_payment_method; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customer_payment_method (id, customer_id, provider_id, data, is_default, label, created_at, updated_at, deleted_at) FROM stdin;
01KT1W29FPE0VRZ66289J2VBKH	cus_01KSR173ECD4A2AJF6H3R1H2J8	stripe	{"brand": "visa", "last4": "0000", "token": "tok_simulated"}	t	Visa	2026-06-01 17:15:34.007+02	2026-06-01 17:15:34.007+02	\N
\.


--
-- Data for Name: daily_check_in; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.daily_check_in (id, checkin_date, streak_count_at_checkin, points_earned, loyalty_id, created_at, updated_at, deleted_at) FROM stdin;
01KZSKXT45QWVH1H89S8JB0MS2	2026-08-12	1	12	01KZSKVSMN35D0B5K3Y3Y8VYNG	2026-08-12 01:53:34.085+02	2026-08-12 01:53:34.085+02	\N
01KZSKXT47XSBV67W0FYFKTSKC	2026-08-12	1	12	01KZSKVSMN35D0B5K3Y3Y8VYNG	2026-08-12 01:53:34.087+02	2026-08-12 01:53:34.087+02	\N
01KZSMBAG2WXPV28RM93QRFMBS	2026-08-12	1	12	01KZSMB2RF3BMZMHR0S0R0SJ6K	2026-08-12 02:00:56.835+02	2026-08-12 02:00:56.835+02	\N
01KZSMYMCBA9PQ3QVAEX8ZH74T	2026-08-12	1	12	01KZSMA4A7553XA5H9TZKBH0E8	2026-08-12 02:11:29.547+02	2026-08-12 02:11:29.547+02	\N
01M03DYCQMMS06G0D9GG0H6NV4	2026-08-15	1	12	01KZSMA4A7553XA5H9TZKBH0E8	2026-08-15 21:21:26.005+02	2026-08-15 21:21:26.005+02	\N
\.


--
-- Data for Name: delivery_company; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.delivery_company (id, name, logo, phone, email, website, is_active, metadata, created_at, updated_at, deleted_at) FROM stdin;
01KTAF6PBVBWHD2ZQ97HZ5AZDA	FedEx	\N	+25767881752	princelulinda@gmail.com	\N	t	\N	2026-06-05 01:23:56.667+02	2026-06-05 01:23:56.667+02	\N
01KTAFPJ1FT8R49AAB3VPMTRVJ	DHL	\N	+25767881752	prinda@gmail.com	\N	t	\N	2026-06-05 01:32:36.528+02	2026-06-05 01:32:36.528+02	\N
\.


--
-- Data for Name: delivery_delivery_company_fulfillment_shipping_option; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.delivery_delivery_company_fulfillment_shipping_option (delivery_company_id, shipping_option_id, id, created_at, updated_at, deleted_at) FROM stdin;
01KTABY13FYX41KY6WMFJDYX5Q	so_01KSWK0MGHVTE3D3GG9BEB4SYS	link_01KTABY1439Q3RRBJMK7JHHRXV	2026-06-05 00:26:47.042471+02	2026-06-05 00:30:54.386+02	2026-06-05 00:30:54.386+02
01KTABZP94RMJMFRSGTH1A3TN1	so_01KT9F4RGG3QH9TJK4RK3B94HP	link_01KTABZP9YPZFXMHTKTKH5S2A3	2026-06-05 00:27:41.501284+02	2026-06-05 00:32:47.349+02	2026-06-05 00:32:47.348+02
01KTAC6E1QBM07S68QHRMT92FC	so_01KTAC4W5KSP7M868818GXGN8V	link_01KTAC6E21NPSBZ7SAR0WZJVVZ	2026-06-05 00:31:22.433119+02	2026-06-05 00:35:51.959+02	2026-06-05 00:35:51.959+02
01KTACFJ3MHX4ZMV7WRG87495B	so_01KTACDA0EX08JWS75B4SW1BDG	link_01KTACFJ48G2DWQMP27TM2B005	2026-06-05 00:36:21.512372+02	2026-06-05 01:21:39.867+02	2026-06-05 01:21:39.867+02
01KTAEEB38CN5G6EX1Y23231BT	so_01KTACDA0EX08JWS75B4SW1BDG	link_01KTAEEB40T6Z4WM3S78KCQTYD	2026-06-05 01:10:38.719451+02	2026-06-05 01:21:39.867+02	2026-06-05 01:21:39.867+02
01KTAEVXZ76XF0VN0BTK78RS3E	so_01KTACDA0EX08JWS75B4SW1BDG	link_01KTAEVY00KBKW8EJK0ZC8GTGF	2026-06-05 01:18:04.030098+02	2026-06-05 01:21:39.867+02	2026-06-05 01:21:39.867+02
01KTAF6PBVBWHD2ZQ97HZ5AZDA	so_01KTAF58PA2C6DZQG2GAR40V2H	link_01KTAF6PC4AXH0N4AMRAN49SZA	2026-06-05 01:23:56.676856+02	2026-06-05 01:23:56.676856+02	\N
01KTAFPJ1FT8R49AAB3VPMTRVJ	so_01KTAF58PA2C6DZQG2GAR40V2H	link_01KTAFPJ1SSVHY4VGXRASQZHSR	2026-06-05 01:32:36.537171+02	2026-06-05 01:32:36.537171+02	\N
01KTAFPJ1FT8R49AAB3VPMTRVJ	so_01KTAFNNF59QWDVTRF6X6WJ9RG	link_01KTAFPJ1YV73ESSW5Q3SGZH6Q	2026-06-05 01:32:36.542404+02	2026-06-05 01:32:36.542404+02	\N
\.


--
-- Data for Name: delivery_driver; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.delivery_driver (id, name, phone, vehicle_details, is_active, metadata, delivery_company_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: flash_sale; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.flash_sale (id, vendor_id, title, banner_color, product_ids, promotion_id, campaign_id, discount_type, discount_value, starts_at, ends_at, is_active, created_at, updated_at, deleted_at) FROM stdin;
01KZSNVQWNJHA9TGKERE144E23	01KZSNE0N2NMDBYY9W8KGY0GJW	Demo Flash Sale	#FF5000	["prod_01KSDEEB3Y6W05F6K2ZV4GC0BM"]	promo_01KZSNVQVHV4YR8R403X1ZZPDG	procamp_01KZSNVQTSDNCNWRT8SHENQX8C	percentage	20	2026-08-12 02:27:23+02	2026-08-12 04:27:23+02	t	2026-08-12 02:27:23.413+02	2026-08-12 02:27:23.413+02	\N
01KZV29F87R4A62SPHG3NRVBR6	01KZSNE0N2NMDBYY9W8KGY0GJW	Vendor-wide sale	#FF5000	\N	promo_01KZV29F639S64PE98E234TFXZ	procamp_01KZV29F4R1GY8TJ1J0A480D8E	percentage	15	2026-08-12 15:23:50+02	2026-08-12 17:23:50+02	t	2026-08-12 15:23:50.663+02	2026-08-12 15:23:50.663+02	\N
\.


--
-- Data for Name: fulfillment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fulfillment (id, location_id, packed_at, shipped_at, delivered_at, canceled_at, data, provider_id, shipping_option_id, metadata, delivery_address_id, created_at, updated_at, deleted_at, marked_shipped_by, created_by, requires_shipping) FROM stdin;
ful_01KSYNRY5QE6WC9XE86D6X2MPW	sloc_01KSF7CHXY413KMNRYZAE8PT2S	2026-05-31 11:27:52.754+02	\N	\N	\N	{}	delivery-company-provider_delivery-company-provider	so_01KSWK0MGHVTE3D3GG9BEB4SYS	\N	fuladdr_01KSYNRY5Q7A8DEBKQTRWZ5E28	2026-05-31 11:27:52.759+02	2026-05-31 11:27:52.759+02	\N	\N	\N	t
ful_01KSYPWSFHJ0HXZSVH3G0SZ4WP	sloc_01KSF7CHXY413KMNRYZAE8PT2S	2026-05-31 11:47:27.596+02	2026-05-31 11:57:42.921+02	2026-05-31 12:04:49.001+02	\N	{}	delivery-company-provider_delivery-company-provider	so_01KSWK0MGHVTE3D3GG9BEB4SYS	\N	fuladdr_01KSYPWSFH0WJPY3XYP4M5F1NQ	2026-05-31 11:47:27.601+02	2026-05-31 12:04:49.016+02	\N	\N	\N	t
ful_01KSYGK32E7WQ4D5YNPM4C9H8C	sloc_01KSF7CHXY413KMNRYZAE8PT2S	2026-05-31 09:57:18.279+02	2026-06-01 09:40:48.88+02	\N	\N	{}	delivery-company-provider_delivery-company-provider	so_01KSWK0MGHVTE3D3GG9BEB4SYS	\N	fuladdr_01KSYGK32E35J1YC4JHGBPNB0X	2026-05-31 09:57:18.287+02	2026-06-01 09:40:48.894+02	\N	\N	\N	t
\.


--
-- Data for Name: fulfillment_address; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fulfillment_address (id, company, first_name, last_name, address_1, address_2, city, country_code, province, postal_code, phone, metadata, created_at, updated_at, deleted_at) FROM stdin;
fuladdr_01KSYGK32E35J1YC4JHGBPNB0X	\N	prince	-	Line 1		Musenyi	bi	\N			\N	2026-05-30 19:35:22.079+02	2026-05-30 19:35:22.079+02	\N
fuladdr_01KSYNRY5Q7A8DEBKQTRWZ5E28	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-31 11:27:03.667+02	2026-05-31 11:27:03.667+02	\N
fuladdr_01KSYPWSFH0WJPY3XYP4M5F1NQ	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-31 11:46:43.692+02	2026-05-31 11:46:43.692+02	\N
\.


--
-- Data for Name: fulfillment_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fulfillment_item (id, title, sku, barcode, quantity, raw_quantity, line_item_id, inventory_item_id, fulfillment_id, created_at, updated_at, deleted_at) FROM stdin;
fulit_01KSYGK32DN7GS1MNRH22TJGAQ	Rouge			1	{"value": "1", "precision": 20}	ordli_01KSWZ94QMZSFYTT7W2RETNS1N	iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	ful_01KSYGK32E7WQ4D5YNPM4C9H8C	2026-05-31 09:57:18.287+02	2026-05-31 09:57:18.287+02	\N
fulit_01KSYNRY5Q5GH2243WZXAYJ2QR	Rouge			1	{"value": "1", "precision": 20}	ordli_01KSYNR3FRS9WA22GY059T0G28	iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	ful_01KSYNRY5QE6WC9XE86D6X2MPW	2026-05-31 11:27:52.759+02	2026-05-31 11:27:52.759+02	\N
fulit_01KSYPWSFH6WRMREBJ75766Q0J	Rouge			3	{"value": "3", "precision": 20}	ordli_01KSYPW2RSYNTHG25MJ844X3J6	iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	ful_01KSYPWSFHJ0HXZSVH3G0SZ4WP	2026-05-31 11:47:27.601+02	2026-05-31 11:47:27.601+02	\N
\.


--
-- Data for Name: fulfillment_label; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fulfillment_label (id, tracking_number, tracking_url, label_url, fulfillment_id, created_at, updated_at, deleted_at) FROM stdin;
fulla_01KSYQFJD1V2B08947A81H24KJ	NIB			ful_01KSYPWSFHJ0HXZSVH3G0SZ4WP	2026-05-31 11:57:42.946+02	2026-05-31 11:57:42.946+02	\N
\.


--
-- Data for Name: fulfillment_provider; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fulfillment_provider (id, is_enabled, created_at, updated_at, deleted_at) FROM stdin;
delivery-company-provider_delivery-company-provider	t	2026-05-30 15:46:27.882+02	2026-05-30 15:46:27.882+02	\N
manual_manual	f	2026-05-24 12:23:06.721+02	2026-05-30 15:46:27.895+02	\N
\.


--
-- Data for Name: fulfillment_set; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fulfillment_set (id, name, type, metadata, created_at, updated_at, deleted_at) FROM stdin;
fuset_01KSR2W2CKBZ3D4B3MB4Y2606S	Bujumbura shipping	shipping	\N	2026-05-28 22:02:05.843+02	2026-05-28 22:02:05.843+02	\N
fuset_01KSCR9E7DBG6TWATM3CH2T54A	European Warehouse delivery	shipping	\N	2026-05-24 12:25:30.861+02	2026-05-30 15:30:55.184+02	2026-05-30 15:30:55.183+02
fuset_01KSWJXMT5RA51MF8N6AK4SGNJ	Bujumbura pick up	pickup	\N	2026-05-30 15:59:32.421+02	2026-05-30 15:59:32.421+02	\N
\.


--
-- Data for Name: geo_zone; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.geo_zone (id, type, country_code, province_code, city, service_zone_id, postal_expression, metadata, created_at, updated_at, deleted_at) FROM stdin;
fgz_01KSR2WQX33Y0M938Q47G1QPN0	country	af	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.884+02	2026-05-28 22:02:27.884+02	\N
fgz_01KSR2WQX3M8QNS2GFGZHSF315	country	al	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.884+02	2026-05-28 22:02:27.884+02	\N
fgz_01KSR2WQX3RYR9QD2GA2A4H57N	country	dz	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.884+02	2026-05-28 22:02:27.884+02	\N
fgz_01KSR2WQX3YF9DE5MD2JM1G4QA	country	as	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.884+02	2026-05-28 22:02:27.884+02	\N
fgz_01KSR2WQX3GX3HEJ5C7EKNFMBZ	country	ad	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.884+02	2026-05-28 22:02:27.884+02	\N
fgz_01KSR2WQX3RVT9KCS4PEC52J7T	country	ao	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.884+02	2026-05-28 22:02:27.884+02	\N
fgz_01KSR2WQX3S0BF1YX3HP7P1AQ7	country	ai	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.884+02	2026-05-28 22:02:27.884+02	\N
fgz_01KSR2WQX4ZBVW01NW143XRERJ	country	aq	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.884+02	2026-05-28 22:02:27.884+02	\N
fgz_01KSR2WQX4TM3QAS04DJKMXRXN	country	ag	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.884+02	2026-05-28 22:02:27.884+02	\N
fgz_01KSR2WQX4PJMNJPCB9MGZNV19	country	ar	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.884+02	2026-05-28 22:02:27.884+02	\N
fgz_01KSR2WQX4HDKPA7KR9Z45J21J	country	am	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.884+02	2026-05-28 22:02:27.884+02	\N
fgz_01KSR2WQX4FRBNWTBECH6D639J	country	aw	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.884+02	2026-05-28 22:02:27.884+02	\N
fgz_01KSR2WQX4PTBX1Z876FEPG95P	country	au	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.884+02	2026-05-28 22:02:27.884+02	\N
fgz_01KSR2WQX43D610D11HT0471G4	country	at	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.884+02	2026-05-28 22:02:27.884+02	\N
fgz_01KSR2WQX410MWEZM78RHQMFJG	country	az	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.884+02	2026-05-28 22:02:27.884+02	\N
fgz_01KSR2WQX45MVG79WGSER3WJW4	country	bs	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.884+02	2026-05-28 22:02:27.884+02	\N
fgz_01KSR2WQX5MAM42A7Q1WNRDS6M	country	bh	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.884+02	2026-05-28 22:02:27.884+02	\N
fgz_01KSR2WQX51MXZQBVKNCCRJB1V	country	bd	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.884+02	2026-05-28 22:02:27.884+02	\N
fgz_01KSR2WQX54YM4QYBAAN2PX4TB	country	bb	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.884+02	2026-05-28 22:02:27.884+02	\N
fgz_01KSR2WQX5QKT2MF87ZS200S68	country	by	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX5NN4X3PYHAV4EMERE	country	be	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX5A19PBJN2PPVKFYKC	country	bz	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX5FFC0NHGXGX2FZCGN	country	bj	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX571W89FP0NCVW75ZF	country	bm	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX54W7HE27KT3QHQ68G	country	bt	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX5P0PRHKT7H8927E97	country	bo	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX6YQGZD6XVAHF77YPJ	country	bq	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX6FEJC1JQ7RNPVRJ2R	country	ba	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX6065W3CE356M9APBJ	country	bw	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX6XZ4WYVC7VTX3YEAJ	country	bv	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX6EPK5HD9BE746S0S4	country	br	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX6PSC2A0AJC7TWFKQ2	country	io	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX6JKSN6DDK29A1RS3N	country	bn	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX6RJ2XQHTSR463C4R5	country	bg	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX68DTC6Z3555PG0D95	country	bf	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX68NACVVVDMZYZAFER	country	bi	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX7NBSS27VTD4F17D5H	country	kh	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX7J0Y5GCY1VMRH2PM5	country	cm	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX7G6R67FFWGHYM5FGT	country	ca	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX77W8M50W2KWF6BNCV	country	cv	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX7VHX7KMJGRX1NYZ4J	country	ky	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX7G4CX0VY8PMSG9JVN	country	cf	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX735KF7BXM7KVB0W3Q	country	td	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX71YHRKJHKWZNSYJHZ	country	cl	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX7F0XJJJRC2DDBZ84D	country	cn	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX72QPZF53JMZP55XV9	country	cx	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX8PZ573HS4P3YRS45Q	country	cc	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQX8YPP42XHHV08PM8JY	country	co	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQXAEGCJ3H1YB5Q0V1VR	country	km	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSR2WQXA6PWZZEN854Y91AGS	country	cg	\N	\N	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	\N	\N	2026-05-28 22:02:27.885+02	2026-05-28 22:02:27.885+02	\N
fgz_01KSCR9E7D2BYAEMVVQB2WTARX	country	gb	\N	\N	serzo_01KSCR9E7DM0H9XA9Y3A0H2YXP	\N	\N	2026-05-24 12:25:30.861+02	2026-05-30 15:30:55.209+02	2026-05-30 15:30:55.183+02
fgz_01KSCR9E7DJRSWGG0QJQN2P9N3	country	de	\N	\N	serzo_01KSCR9E7DM0H9XA9Y3A0H2YXP	\N	\N	2026-05-24 12:25:30.861+02	2026-05-30 15:30:55.209+02	2026-05-30 15:30:55.183+02
fgz_01KSCR9E7DFT3WEZ9GHKZ8KPMJ	country	dk	\N	\N	serzo_01KSCR9E7DM0H9XA9Y3A0H2YXP	\N	\N	2026-05-24 12:25:30.861+02	2026-05-30 15:30:55.209+02	2026-05-30 15:30:55.183+02
fgz_01KSCR9E7D7WX6AWB6PH4VG9GV	country	se	\N	\N	serzo_01KSCR9E7DM0H9XA9Y3A0H2YXP	\N	\N	2026-05-24 12:25:30.861+02	2026-05-30 15:30:55.209+02	2026-05-30 15:30:55.183+02
fgz_01KSCR9E7DFYW8QVJPDQYTBKYZ	country	fr	\N	\N	serzo_01KSCR9E7DM0H9XA9Y3A0H2YXP	\N	\N	2026-05-24 12:25:30.861+02	2026-05-30 15:30:55.209+02	2026-05-30 15:30:55.183+02
fgz_01KSCR9E7DFMWNA7DNNSQS6AVN	country	es	\N	\N	serzo_01KSCR9E7DM0H9XA9Y3A0H2YXP	\N	\N	2026-05-24 12:25:30.861+02	2026-05-30 15:30:55.209+02	2026-05-30 15:30:55.183+02
fgz_01KSCR9E7D1XMANDJQNQEDMQSD	country	it	\N	\N	serzo_01KSCR9E7DM0H9XA9Y3A0H2YXP	\N	\N	2026-05-24 12:25:30.861+02	2026-05-30 15:30:55.209+02	2026-05-30 15:30:55.183+02
fgz_01KSWJYMRT06A49SXHPT9K4XNC	country	af	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRTBEDXXFFBNKM58A9W	country	al	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRTWW62EC6X1QT9CQRF	country	dz	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRTWZHG7HMWYFW5HSTM	country	as	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRTPH3GKQFJ9HSB2X9X	country	ad	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRTJTXKWQF2AHPP0AVK	country	ao	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRVYP6B069T0ZY529KD	country	ai	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRV7WVKFAA5WR43TJE0	country	aq	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRVM24QGAX7S1Q8EXZW	country	ag	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRV11RTQ48EP5QK02AX	country	ar	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRVF7DDYMB4Y6DQJ94H	country	am	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRVHN6F589ZDWA31TJ0	country	aw	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRV2XB5ESBHG9PB82BR	country	au	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRVE54993PEQR3ZX9P5	country	at	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRWCJ30N3BEXKM30P39	country	az	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRWF3NF4958WN4870FN	country	bs	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRW5ATG3X4TZT8M0982	country	bh	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRW1RPWTMMWKHCK1CSS	country	bd	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRWJCFP1AYX3N8J5A1Y	country	bb	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRWHTH3VZTK7G8JB7EY	country	by	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRWTPKDMMVMHDX6KBXD	country	be	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRWVCEQJWP1W030WX5S	country	bz	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRX2J3DF2WNB4G4B8F2	country	bj	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRX97KRGCTWRF78ZMCB	country	bm	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRX8ZMD9RFAC37VY898	country	bt	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRXMCXXY2D0CB7ETDV3	country	bo	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRXFC598CAWPKR7Z510	country	bq	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRX67SRS4W43HQC3QT3	country	ba	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRXFWZ8W16G3Y8PQKK0	country	bw	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRX6CK705RJRHYV5BYQ	country	bv	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRXCE6YZ450FWTPM51R	country	br	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRYJEFDDQREDVF7KRP1	country	io	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRYS545S4SA5XB62JH3	country	bn	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRYA18HM5AAC6HJ0T73	country	bg	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRY1XME7NZ7VR591W96	country	bf	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRY1419ZQBP6ZHQFXPR	country	bi	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRY0KGYT4Q5TKPEV2ZH	country	kh	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRY14BB384HS9FNWTXC	country	cm	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRY9GT9WFXKC3ETEZ45	country	ca	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRY0JZ28FPD4X160RET	country	cv	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRYG48SQN0J1RBET11V	country	ky	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRYFR1R8FHGADF0F697	country	cf	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRY8NF4P96KXYXSJ335	country	td	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRYJTRZ5GX03FFWN47P	country	cl	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRZTHCXYQ8WGHCPBT1K	country	cn	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRZW2T9MRWTCV7XPWMD	country	cx	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRZQSD5ZHMYNVGZHPTH	country	cc	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRZA1CZ5WXXEJF1BRD5	country	co	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRZVKKK6G4KEFZB1QM2	country	km	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
fgz_01KSWJYMRZ67XDKJC3Q2TV4811	country	cg	\N	\N	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	\N	\N	2026-05-30 16:00:05.152+02	2026-05-30 16:00:05.152+02	\N
\.


--
-- Data for Name: image; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.image (id, url, metadata, created_at, updated_at, deleted_at, rank, product_id) FROM stdin;
img_01KSCR9EAARFD3WW3BKH0T8AWN	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-front.png	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N	0	prod_01KSCR9EA8QJ19M3XNSJCQTBKP
img_01KSCR9EAADB0R7KPQWQ9WW3MD	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-back.png	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N	1	prod_01KSCR9EA8QJ19M3XNSJCQTBKP
img_01KSCR9EAA0V50D5FSBPEB8AVZ	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-white-front.png	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N	2	prod_01KSCR9EA8QJ19M3XNSJCQTBKP
img_01KSCR9EAA3V7774NZTQS97R5M	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-white-back.png	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N	3	prod_01KSCR9EA8QJ19M3XNSJCQTBKP
img_01KSCR9EAB25RERWNHY91SCD50	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatshirt-vintage-front.png	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N	0	prod_01KSCR9EA893MYMWYSTYVN97YD
img_01KSCR9EAB0G41GDJXFYGX42T8	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatshirt-vintage-back.png	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N	1	prod_01KSCR9EA893MYMWYSTYVN97YD
img_01KSCR9EACCA71DYAP0TRGZ30K	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatpants-gray-front.png	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N	0	prod_01KSCR9EA81H268P4TP8HZKH76
img_01KSCR9EAC1MXWH92H4AG21JS4	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatpants-gray-back.png	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N	1	prod_01KSCR9EA81H268P4TP8HZKH76
img_01KSCR9EACNQ5RHCND2TQVWE7R	https://medusa-public-images.s3.eu-west-1.amazonaws.com/shorts-vintage-front.png	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N	0	prod_01KSCR9EA8NPXFPM0RR3W38Q5X
img_01KSCR9EACYJW3P50ZDP58SKXE	https://medusa-public-images.s3.eu-west-1.amazonaws.com/shorts-vintage-back.png	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N	1	prod_01KSCR9EA8NPXFPM0RR3W38Q5X
img_01KSDEEB3ZR8DQE7SGJGHPT3J3	http://localhost:9000/static/1779641482219-image.jpg	\N	2026-05-24 18:52:40.192+02	2026-05-24 18:52:40.192+02	\N	0	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM
img_01KSDEEB3ZFVWC3ZNSXQ6VX51M	http://localhost:9000/static/1779641482473-image.jpg	\N	2026-05-24 18:52:40.192+02	2026-05-24 18:52:40.192+02	\N	1	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM
img_01KSDEEB3ZYDYCDG2X315XASW2	http://localhost:9000/static/1779641482797-image.jpg	\N	2026-05-24 18:52:40.192+02	2026-05-24 18:52:40.192+02	\N	2	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM
img_01KSDEEB3Z4F5Y3JD6MV78DF5V	http://localhost:9000/static/1779641483400-image.jpg	\N	2026-05-24 18:52:40.192+02	2026-05-24 18:52:40.192+02	\N	3	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM
img_01KSDEEB3ZCZ3C01WD2TSQ896M	http://localhost:9000/static/1779641484195-image.jpg	\N	2026-05-24 18:52:40.192+02	2026-05-24 18:52:40.192+02	\N	4	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM
img_01KSH2A8YRMG0MFYG1WY7KWM22	http://localhost:9000/static/1779763040657-image.jpg	\N	2026-05-26 04:37:41.721+02	2026-05-26 04:37:41.721+02	\N	0	prod_01KSH2A8YPQ2M4AN368YBJ9X3C
img_01KSH2A8YRYB9AR4X37BKENY6R	http://localhost:9000/static/1779763040787-image.jpg	\N	2026-05-26 04:37:41.721+02	2026-05-26 04:37:41.721+02	\N	1	prod_01KSH2A8YPQ2M4AN368YBJ9X3C
img_01KSH2A8YRVPK6AHA0BST16V2N	http://localhost:9000/static/1779763040896-image.jpg	\N	2026-05-26 04:37:41.721+02	2026-05-26 04:37:41.721+02	\N	2	prod_01KSH2A8YPQ2M4AN368YBJ9X3C
img_01KT156V017GN3YB7AA5BS7J28	http://localhost:9000/static/1780302709862-image.jpg	\N	2026-06-01 10:36:05.763+02	2026-06-01 10:36:05.763+02	\N	0	prod_01KT156V00QYP2NS7HYG4BWMYG
img_01KT156V01EYM1WTT8EP521W44	http://localhost:9000/static/1780302709971-image.jpg	\N	2026-06-01 10:36:05.763+02	2026-06-01 10:36:05.763+02	\N	1	prod_01KT156V00QYP2NS7HYG4BWMYG
img_01KT156V01ZH6VC15PDGAQS5G0	http://localhost:9000/static/1780302710137-image.jpg	\N	2026-06-01 10:36:05.763+02	2026-06-01 10:36:05.763+02	\N	2	prod_01KT156V00QYP2NS7HYG4BWMYG
img_01KT156V021G6MQ7R0RYGDG486	http://localhost:9000/static/1780302710382-image.jpg	\N	2026-06-01 10:36:05.763+02	2026-06-01 10:36:05.763+02	\N	3	prod_01KT156V00QYP2NS7HYG4BWMYG
img_01KT156V02JX5T94HFYYR0WJ0N	http://localhost:9000/static/1780302710563-image.jpg	\N	2026-06-01 10:36:05.763+02	2026-06-01 10:36:05.763+02	\N	4	prod_01KT156V00QYP2NS7HYG4BWMYG
img_01KT156V02VF5KKCB8QRC5N0CQ	http://localhost:9000/static/1780302710707-image.jpg	\N	2026-06-01 10:36:05.763+02	2026-06-01 10:36:05.763+02	\N	5	prod_01KT156V00QYP2NS7HYG4BWMYG
img_01KTJ4K77FN0NWRXAFM28VXG5V	https://minio.afyaclick.bi/eastmarket/icon-01KTJ4K51VVNM74F64H1PF37EA.png	\N	2026-06-08 00:52:28.272+02	2026-06-08 01:10:45.827+02	2026-06-08 01:10:45.808+02	0	prod_01KTJ4K77CRV73SNDHAGTJSC32
img_01KV5D7S5CP2X66F3EBX3FF6NB	https://s3.eastmarket.africa/eastmarket/image-01KV5D13J6R2NW8G1966SMY1G3.jpg	\N	2026-06-15 12:29:04.815+02	2026-06-15 12:29:04.815+02	\N	0	prod_01KV5D7S5A3GT3TNV6JJ36QA88
img_01KV5D7S5C126N3CNXR3BM4PN3	https://s3.eastmarket.africa/eastmarket/image-01KV5D15FBD0RT3VHF8K338YWQ.jpg	\N	2026-06-15 12:29:04.815+02	2026-06-15 12:29:04.815+02	\N	1	prod_01KV5D7S5A3GT3TNV6JJ36QA88
img_01KV5D7S5C54426FK1AXPXXE3Y	https://s3.eastmarket.africa/eastmarket/image-01KV5D17MMK71DEKQ5PYSJJNAJ.jpg	\N	2026-06-15 12:29:04.815+02	2026-06-15 12:29:04.815+02	\N	2	prod_01KV5D7S5A3GT3TNV6JJ36QA88
img_01KV5D7S5CF475D8FG6038T80Y	https://s3.eastmarket.africa/eastmarket/image-01KV5D1AFHC3EFW3M56YTKPTWH.jpg	\N	2026-06-15 12:29:04.815+02	2026-06-15 12:29:04.815+02	\N	3	prod_01KV5D7S5A3GT3TNV6JJ36QA88
img_01KV5D7S5CAKNEKCM5WM4SPYE2	https://s3.eastmarket.africa/eastmarket/image-01KV5D1C8WED4T6P54KQJQH704.jpg	\N	2026-06-15 12:29:04.815+02	2026-06-15 12:29:04.815+02	\N	4	prod_01KV5D7S5A3GT3TNV6JJ36QA88
img_01KV5D7S5CQ8VXXBF1V2VG33ZC	https://s3.eastmarket.africa/eastmarket/image-01KV5D1E28PPHTQ67Q1YTBFECM.jpg	\N	2026-06-15 12:29:04.815+02	2026-06-15 12:29:04.815+02	\N	5	prod_01KV5D7S5A3GT3TNV6JJ36QA88
img_01KV5D7S5C37VC1KKTQK3PRVDA	https://s3.eastmarket.africa/eastmarket/image-01KV5D1G9ZR2ZEZ8GC505XR0FH.jpg	\N	2026-06-15 12:29:04.815+02	2026-06-15 12:29:04.815+02	\N	6	prod_01KV5D7S5A3GT3TNV6JJ36QA88
img_01KVANBHYW12CHXXM9C3MRX6SC	https://s3.eastmarket.africa/eastmarket/image-01KVAN6DH62MSTWWS69F7JRS3N.jpg	\N	2026-06-17 13:27:09.278+02	2026-06-17 13:27:09.278+02	\N	0	prod_01KVANBHYVPHYHTH3VKVZDF1VJ
img_01KVANBHYWDE1PJ3SX3YHNA7ZP	https://s3.eastmarket.africa/eastmarket/image-01KVAN6FKPDYZWG2B7800THZDY.jpg	\N	2026-06-17 13:27:09.278+02	2026-06-17 13:27:09.278+02	\N	1	prod_01KVANBHYVPHYHTH3VKVZDF1VJ
img_01KVANBHYXQG8KE1T73SBRZ53A	https://s3.eastmarket.africa/eastmarket/image-01KVAN6N6FW7JPK9ASH4KXZWKH.jpg	\N	2026-06-17 13:27:09.278+02	2026-06-17 13:27:09.278+02	\N	2	prod_01KVANBHYVPHYHTH3VKVZDF1VJ
img_01KVANBHYX8JKV0D0MN2A0X0RW	https://s3.eastmarket.africa/eastmarket/image-01KVAN6ST38X8J850KVTEY1V1D.jpg	\N	2026-06-17 13:27:09.278+02	2026-06-17 13:27:09.278+02	\N	3	prod_01KVANBHYVPHYHTH3VKVZDF1VJ
img_01KVANBHYXEYBFQY1A7E6H5YBC	https://s3.eastmarket.africa/eastmarket/image-01KVAN6XDYJYWAR7ZQF2VP53JY.jpg	\N	2026-06-17 13:27:09.278+02	2026-06-17 13:27:09.278+02	\N	4	prod_01KVANBHYVPHYHTH3VKVZDF1VJ
img_01KVANBHYXRXF3KCA6HQTV47YH	https://s3.eastmarket.africa/eastmarket/image-01KVAN739R6XCMPSHZWW8F6B55.jpg	\N	2026-06-17 13:27:09.278+02	2026-06-17 13:27:09.278+02	\N	5	prod_01KVANBHYVPHYHTH3VKVZDF1VJ
img_01KVAM3934N8NTDKXWVA4ASJW9	https://s3.eastmarket.africa/eastmarket/image-01KVAM2Q1N445NR3P1HVQK6V1P.jpg	\N	2026-06-17 13:05:09.477+02	2026-06-17 13:05:09.477+02	\N	0	prod_01KV5DWPN1992BC1RARAP2H0K1
img_01KVAM3934G6RCAR2XNCSJ7EBY	https://s3.eastmarket.africa/eastmarket/image-01KVAM314X72WJ3DDYPWX2WXH7.jpg	\N	2026-06-17 13:05:09.477+02	2026-06-17 13:05:09.477+02	\N	1	prod_01KV5DWPN1992BC1RARAP2H0K1
img_01KV5H8J0YE8DPP5ZN4R3ENJC4	https://s3.eastmarket.africa/eastmarket/image-01KV5H6NG3D61DR9K4T2Y5MA7C.jpg	\N	2026-06-15 13:39:24.577+02	2026-06-15 13:39:24.577+02	\N	0	prod_01KV5H8J0X1ZXZA46EZ0MG683D
img_01KV5H8J0Y3CMS0KE4423R14TG	https://s3.eastmarket.africa/eastmarket/image-01KV5H6SMDY2925RK9N3N2M1FB.jpg	\N	2026-06-15 13:39:24.577+02	2026-06-15 13:39:24.577+02	\N	1	prod_01KV5H8J0X1ZXZA46EZ0MG683D
img_01KV5H8J0ZPVQBKA8MYQ177Y4S	https://s3.eastmarket.africa/eastmarket/image-01KV5H6YWK9N543E61NF4XT968.jpg	\N	2026-06-15 13:39:24.577+02	2026-06-15 13:39:24.577+02	\N	2	prod_01KV5H8J0X1ZXZA46EZ0MG683D
img_01KV5H8J0Z49JY7RFB4E1D0XFV	https://s3.eastmarket.africa/eastmarket/image-01KV5H71N1K34YQYRS7DKFS4DV.jpg	\N	2026-06-15 13:39:24.577+02	2026-06-15 13:39:24.577+02	\N	3	prod_01KV5H8J0X1ZXZA46EZ0MG683D
img_01KV5H8J0ZW9CKHPGG7XF2Z8N3	https://s3.eastmarket.africa/eastmarket/image-01KV5H77VB2K9YTZ6BD4K1VABV.jpg	\N	2026-06-15 13:39:24.577+02	2026-06-15 13:39:24.577+02	\N	4	prod_01KV5H8J0X1ZXZA46EZ0MG683D
img_01KV5H8J0ZQ6T44FF8VVYJW21C	https://s3.eastmarket.africa/eastmarket/image-01KV5H7CQXE6PCW0VXXMSE3WR0.jpg	\N	2026-06-15 13:39:24.577+02	2026-06-15 13:39:24.577+02	\N	5	prod_01KV5H8J0X1ZXZA46EZ0MG683D
img_01KV5H8J0Z2KVMRC9M34FZ0S6R	https://s3.eastmarket.africa/eastmarket/image-01KV5H7F2YAP45VQKPZ5ZHD2JX.jpg	\N	2026-06-15 13:39:24.577+02	2026-06-15 13:39:24.577+02	\N	6	prod_01KV5H8J0X1ZXZA46EZ0MG683D
img_01KV5H8J0ZSCK6D2ESEW88V0HA	https://s3.eastmarket.africa/eastmarket/image-01KV5H7JVYDG3TGQGQK05GSJEK.jpg	\N	2026-06-15 13:39:24.577+02	2026-06-15 13:39:24.577+02	\N	7	prod_01KV5H8J0X1ZXZA46EZ0MG683D
img_01KWTK7AZAERZ8FEEXKSBB6309	https://s3.eastmarket.africa/eastmarket/image-01KWT4FXDQ78MMRJQZR3G7FVA4.jpg	\N	2026-07-06 04:13:26.635+02	2026-07-06 04:22:16.266+02	2026-07-06 04:22:16.259+02	0	prod_01KWT4YBXAFKGSHX0R820VDJS4
img_01KWTK7AZAATW4ZT8XFK124H8H	https://s3.eastmarket.africa/eastmarket/image-01KWT4FZQ87V7PP3AWDQXYZ6YE.jpg	\N	2026-07-06 04:13:26.635+02	2026-07-06 04:22:16.266+02	2026-07-06 04:22:16.259+02	1	prod_01KWT4YBXAFKGSHX0R820VDJS4
img_01KWTK7AZAYNTAKP11RPAHC36A	https://s3.eastmarket.africa/eastmarket/image-01KWT4G2V0NVS4NAH9VJE6PQN1.jpg	\N	2026-07-06 04:13:26.635+02	2026-07-06 04:22:16.266+02	2026-07-06 04:22:16.259+02	2	prod_01KWT4YBXAFKGSHX0R820VDJS4
img_01KWTK7AZA7B5SKVPMDF9018W4	https://s3.eastmarket.africa/eastmarket/image-01KWT4G55M9SX6JBVHJNK8G9FD.jpg	\N	2026-07-06 04:13:26.635+02	2026-07-06 04:22:16.266+02	2026-07-06 04:22:16.259+02	3	prod_01KWT4YBXAFKGSHX0R820VDJS4
img_01KWTK7AZA4SEEH21MNWPHMEB8	https://s3.eastmarket.africa/eastmarket/image-01KWT4G6W5X7GW1FY50765A88D.jpg	\N	2026-07-06 04:13:26.635+02	2026-07-06 04:22:16.266+02	2026-07-06 04:22:16.259+02	4	prod_01KWT4YBXAFKGSHX0R820VDJS4
img_01KWTK7AZA1SPF38ZACK4D5VXQ	https://s3.eastmarket.africa/eastmarket/image-01KWT4G92FXMHN8HBY4QGV5E8B.jpg	\N	2026-07-06 04:13:26.635+02	2026-07-06 04:22:16.266+02	2026-07-06 04:22:16.259+02	5	prod_01KWT4YBXAFKGSHX0R820VDJS4
img_01KWTK7AZA5YMHAYQ2AP2JBCQE	https://s3.eastmarket.africa/eastmarket/image-01KWT4GCT0E07E3MX15X2CX20X.jpg	\N	2026-07-06 04:13:26.635+02	2026-07-06 04:22:16.266+02	2026-07-06 04:22:16.259+02	6	prod_01KWT4YBXAFKGSHX0R820VDJS4
img_01KWTKZBN27ZFJ21MZN67JHZRD	https://s3.eastmarket.africa/eastmarket/image-01KWTKVV2H2M65YENN1QQ6EMKH.jpg	\N	2026-07-06 04:26:33.763+02	2026-07-06 04:26:33.763+02	\N	0	prod_01KWTKZBN13GNZVP6YNBMAD3VP
img_01KWTKZBN2NV0Y8M0RWG70ZQBJ	https://s3.eastmarket.africa/eastmarket/image-01KWTKVWVJR0PWJ3R2MG7VGZP2.jpg	\N	2026-07-06 04:26:33.763+02	2026-07-06 04:26:33.763+02	\N	1	prod_01KWTKZBN13GNZVP6YNBMAD3VP
img_01KWTKZBN2BXW50TZS7NXHJ2TR	https://s3.eastmarket.africa/eastmarket/image-01KWTKVYK6C0JVQ0Z3KW1CMM8S.jpg	\N	2026-07-06 04:26:33.763+02	2026-07-06 04:26:33.763+02	\N	2	prod_01KWTKZBN13GNZVP6YNBMAD3VP
img_01KWTKZBN2SPYW2MXNPJ2BBGAZ	https://s3.eastmarket.africa/eastmarket/image-01KWTKW08C50JWMM793J1DXVHW.jpg	\N	2026-07-06 04:26:33.763+02	2026-07-06 04:26:33.763+02	\N	3	prod_01KWTKZBN13GNZVP6YNBMAD3VP
img_01KWTKZBN21CZGMT6297GW0D5N	https://s3.eastmarket.africa/eastmarket/image-01KWTKW21BZ3D6CNEKF6J5XZB0.jpg	\N	2026-07-06 04:26:33.763+02	2026-07-06 04:26:33.763+02	\N	4	prod_01KWTKZBN13GNZVP6YNBMAD3VP
img_01KWTKZBN2K1YKBHCBMNK956YX	https://s3.eastmarket.africa/eastmarket/image-01KWTKW3JJT2CP3AMSQ23ZDM6M.jpg	\N	2026-07-06 04:26:33.763+02	2026-07-06 04:26:33.763+02	\N	5	prod_01KWTKZBN13GNZVP6YNBMAD3VP
img_01KWTKZBN2QX866T2AHNEYJY79	https://s3.eastmarket.africa/eastmarket/image-01KWTKW58H3WJKB29ZHBDJFG74.jpg	\N	2026-07-06 04:26:33.763+02	2026-07-06 04:26:33.763+02	\N	6	prod_01KWTKZBN13GNZVP6YNBMAD3VP
img_01KWTKZBN2V0EF9FVBKQ0VPXX5	https://s3.eastmarket.africa/eastmarket/image-01KWTKW7WB94NEBMDG3SY2XH89.jpg	\N	2026-07-06 04:26:33.763+02	2026-07-06 04:26:33.763+02	\N	7	prod_01KWTKZBN13GNZVP6YNBMAD3VP
img_01KV5NRAEZQ1J11D0F7RV1WQHZ	https://s3.eastmarket.africa/eastmarket/image-01KV5E4GMW45D7C631PSDBJWB2.jpg	\N	2026-06-15 14:57:55.424+02	2026-06-15 14:57:55.424+02	\N	0	prod_01KV5E601185BKG901X7QG2CEW
img_01KV5NRAEZGDM222FNFHEFQBW3	https://s3.eastmarket.africa/eastmarket/image-01KV5E4TN5794FV7SP380Y5PMR.jpg	\N	2026-06-15 14:57:55.425+02	2026-06-15 14:57:55.425+02	\N	1	prod_01KV5E601185BKG901X7QG2CEW
img_01KV5NRAEZQKKCEQ4WTVNG358J	https://s3.eastmarket.africa/eastmarket/image-01KV5E4YHPNKYE9WCARNGP59ZG.jpg	\N	2026-06-15 14:57:55.425+02	2026-06-15 14:57:55.425+02	\N	2	prod_01KV5E601185BKG901X7QG2CEW
img_01KV5NRAEZZ8884VA0CAFSZADW	https://s3.eastmarket.africa/eastmarket/image-01KV5E52SCS5GBVGMN0S7VHE65.jpg	\N	2026-06-15 14:57:55.425+02	2026-06-15 14:57:55.425+02	\N	3	prod_01KV5E601185BKG901X7QG2CEW
img_01KV5NRAEZW68XN58NJVH5W6YJ	https://s3.eastmarket.africa/eastmarket/image-01KV5E57CPTXN0CNWQGP9H2EW5.jpg	\N	2026-06-15 14:57:55.425+02	2026-06-15 14:57:55.425+02	\N	4	prod_01KV5E601185BKG901X7QG2CEW
img_01KV61DYFCVZ0ECB6VBEYY1Y7K	https://s3.eastmarket.africa/eastmarket/image-01KV5DMAN6NY8VEXS535R9A7H6.jpg	\N	2026-06-15 18:21:58.384+02	2026-06-15 18:21:58.384+02	\N	0	prod_01KV5DPWQMJ87E724G2PHS05ZZ
img_01KV61DYFDWNVJMD1KF6F7F7FY	https://s3.eastmarket.africa/eastmarket/image-01KV5DMKHYEAEND1CN85EA31QP.jpg	\N	2026-06-15 18:21:58.385+02	2026-06-15 18:21:58.385+02	\N	1	prod_01KV5DPWQMJ87E724G2PHS05ZZ
img_01KV61DYFD1M8HPFX8TRFP1252	https://s3.eastmarket.africa/eastmarket/image-01KV5DMVTZ03Y347H7GNH9P3K7.jpg	\N	2026-06-15 18:21:58.385+02	2026-06-15 18:21:58.385+02	\N	2	prod_01KV5DPWQMJ87E724G2PHS05ZZ
img_01KV61DYFDZ6ZX1ZXH016S875X	https://s3.eastmarket.africa/eastmarket/image-01KV5DN1JQB7KZ9ES50BM3E1FJ.jpg	\N	2026-06-15 18:21:58.385+02	2026-06-15 18:21:58.385+02	\N	3	prod_01KV5DPWQMJ87E724G2PHS05ZZ
img_01KV61DYFEKF9SFY3D85GCSQEJ	https://s3.eastmarket.africa/eastmarket/image-01KV5DNAV94W44FM79S1ZJHNXY.jpg	\N	2026-06-15 18:21:58.385+02	2026-06-15 18:21:58.385+02	\N	4	prod_01KV5DPWQMJ87E724G2PHS05ZZ
img_01KV61DYFERK0CPDDA7W1Q2AG8	https://s3.eastmarket.africa/eastmarket/image-01KV5DNFMK4ZCE0F5T397STW2D.jpg	\N	2026-06-15 18:21:58.385+02	2026-06-15 18:21:58.385+02	\N	5	prod_01KV5DPWQMJ87E724G2PHS05ZZ
img_01KV61DYFEG15V4NAVW26WWTSG	https://s3.eastmarket.africa/eastmarket/image-01KV5DNQ62WC1VYYPVEN8GDRQR.jpg	\N	2026-06-15 18:21:58.385+02	2026-06-15 18:21:58.385+02	\N	6	prod_01KV5DPWQMJ87E724G2PHS05ZZ
img_01KV61DYFE67FDYV7GPGYGZCCK	https://s3.eastmarket.africa/eastmarket/image-01KV5DNVRMK0TK7V42XC1YZJS1.jpg	\N	2026-06-15 18:21:58.385+02	2026-06-15 18:21:58.385+02	\N	7	prod_01KV5DPWQMJ87E724G2PHS05ZZ
img_01KVAN3B8QAERAAJA4PP34W5D7	https://s3.eastmarket.africa/eastmarket/image-01KVAGYGR5HSSKB5HN5VY7MM8M.jpg	\N	2026-06-17 13:22:40.281+02	2026-06-17 13:22:40.281+02	\N	0	prod_01KVAHVT1115P37Z781SCQWX1W
img_01KVAG336YCN8SWX2QGN55QH8W	https://s3.eastmarket.africa/eastmarket/image-01KV5JR733EB6YJ4A4G4TNYWNN.jpg	\N	2026-06-17 11:55:09.151+02	2026-06-17 11:55:09.151+02	\N	0	prod_01KV5K1Y66BRSD3K4GDMN4M1YS
img_01KVAG336YASYE4HBFT2CC0Y44	https://s3.eastmarket.africa/eastmarket/image-01KV5JRAPQB2FXFFXK79272ZP2.jpg	\N	2026-06-17 11:55:09.151+02	2026-06-17 11:55:09.151+02	\N	1	prod_01KV5K1Y66BRSD3K4GDMN4M1YS
img_01KVAG336YP6HJ6DKS4M6PYD63	https://s3.eastmarket.africa/eastmarket/image-01KV5JRRG20A80BP2B80ZTSC29.jpg	\N	2026-06-17 11:55:09.151+02	2026-06-17 11:55:09.151+02	\N	2	prod_01KV5K1Y66BRSD3K4GDMN4M1YS
img_01KVAG336YHY76YJWWS7JYSF0Z	https://s3.eastmarket.africa/eastmarket/image-01KV5JS3PFQVEDVEBS0NP2MC1X.jpg	\N	2026-06-17 11:55:09.151+02	2026-06-17 11:55:09.151+02	\N	3	prod_01KV5K1Y66BRSD3K4GDMN4M1YS
img_01KVAG336YYYT7KRBSSV5D22YA	https://s3.eastmarket.africa/eastmarket/image-01KV5JS796S9MW35ZSBS6FG7ZF.jpg	\N	2026-06-17 11:55:09.151+02	2026-06-17 11:55:09.151+02	\N	4	prod_01KV5K1Y66BRSD3K4GDMN4M1YS
img_01KVAN3B8RHTEYNKNNTX5Q70Q0	https://s3.eastmarket.africa/eastmarket/image-01KVAGYPYRM3KFMN1MA1V79MRR.jpg	\N	2026-06-17 13:22:40.282+02	2026-06-17 13:22:40.282+02	\N	1	prod_01KVAHVT1115P37Z781SCQWX1W
img_01KVAN3B8RSB4HB2EJ9A56NTEF	https://s3.eastmarket.africa/eastmarket/image-01KVAGYX2XRGSEM2ZN3RB25A0F.jpg	\N	2026-06-17 13:22:40.282+02	2026-06-17 13:22:40.282+02	\N	2	prod_01KVAHVT1115P37Z781SCQWX1W
img_01KVAN3B8RWKSMSDSM00ZHX6SZ	https://s3.eastmarket.africa/eastmarket/image-01KVAGZ43DAF3T23CHD6X0QKV2.jpg	\N	2026-06-17 13:22:40.282+02	2026-06-17 13:22:40.282+02	\N	3	prod_01KVAHVT1115P37Z781SCQWX1W
img_01KVAN3B8R2122KKE3EZ56A54W	https://s3.eastmarket.africa/eastmarket/image-01KVAGZ9R2R5DZ7KRJTQ6V1B59.jpg	\N	2026-06-17 13:22:40.282+02	2026-06-17 13:22:40.282+02	\N	4	prod_01KVAHVT1115P37Z781SCQWX1W
img_01KVAN3B8RY46E2K5E45E6CQZ3	https://s3.eastmarket.africa/eastmarket/image-01KVAGZCSTFA4TT3RSBC90Q2Z1.jpg	\N	2026-06-17 13:22:40.282+02	2026-06-17 13:22:40.282+02	\N	5	prod_01KVAHVT1115P37Z781SCQWX1W
img_01KVAN3B8R62K1VX2849WYM8B1	https://s3.eastmarket.africa/eastmarket/image-01KVAGZFYG7VA6J6XXHBVHFNSH.jpg	\N	2026-06-17 13:22:40.282+02	2026-06-17 13:22:40.282+02	\N	6	prod_01KVAHVT1115P37Z781SCQWX1W
img_01KVAN3B8RE5EQKRTHGRC2RTN7	https://s3.eastmarket.africa/eastmarket/image-01KVAGZKST84XXRAN5XP6E6K3D.jpg	\N	2026-06-17 13:22:40.282+02	2026-06-17 13:22:40.282+02	\N	7	prod_01KVAHVT1115P37Z781SCQWX1W
img_01KWTK7AZAKC1864S0G9MF57TP	https://s3.eastmarket.africa/eastmarket/image-01KWT4GJAR4W616304SN48RS39.jpg	\N	2026-07-06 04:13:26.635+02	2026-07-06 04:22:16.266+02	2026-07-06 04:22:16.259+02	7	prod_01KWT4YBXAFKGSHX0R820VDJS4
\.


--
-- Data for Name: inventory_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inventory_item (id, created_at, updated_at, deleted_at, sku, origin_country, hs_code, mid_code, material, weight, length, height, width, requires_shipping, description, title, thumbnail, metadata) FROM stdin;
iitem_01KSCR9EC0PDSZC7VWWAAGC01V	2026-05-24 12:25:31.009+02	2026-05-24 12:25:31.009+02	\N	SHIRT-S-BLACK	\N	\N	\N	\N	\N	\N	\N	\N	t	S / Black	S / Black	\N	\N
iitem_01KSCR9EC1HB8C05V1RH1RQR94	2026-05-24 12:25:31.01+02	2026-05-24 12:25:31.01+02	\N	SHIRT-S-WHITE	\N	\N	\N	\N	\N	\N	\N	\N	t	S / White	S / White	\N	\N
iitem_01KSCR9EC17E675WBKDD899K3M	2026-05-24 12:25:31.01+02	2026-05-24 12:25:31.01+02	\N	SHIRT-M-BLACK	\N	\N	\N	\N	\N	\N	\N	\N	t	M / Black	M / Black	\N	\N
iitem_01KSCR9EC120WWXK3AG603G67K	2026-05-24 12:25:31.01+02	2026-05-24 12:25:31.01+02	\N	SHIRT-M-WHITE	\N	\N	\N	\N	\N	\N	\N	\N	t	M / White	M / White	\N	\N
iitem_01KSCR9EC1FD0YB5N181ZEN081	2026-05-24 12:25:31.01+02	2026-05-24 12:25:31.01+02	\N	SHIRT-L-BLACK	\N	\N	\N	\N	\N	\N	\N	\N	t	L / Black	L / Black	\N	\N
iitem_01KSCR9EC1C7TWEQCB8E7ANMF8	2026-05-24 12:25:31.01+02	2026-05-24 12:25:31.01+02	\N	SHIRT-L-WHITE	\N	\N	\N	\N	\N	\N	\N	\N	t	L / White	L / White	\N	\N
iitem_01KSCR9EC1ZGRZB2CBZENPWJC4	2026-05-24 12:25:31.01+02	2026-05-24 12:25:31.01+02	\N	SHIRT-XL-BLACK	\N	\N	\N	\N	\N	\N	\N	\N	t	XL / Black	XL / Black	\N	\N
iitem_01KSCR9EC1Y0GE50A6RKZ6Q7RP	2026-05-24 12:25:31.01+02	2026-05-24 12:25:31.01+02	\N	SHIRT-XL-WHITE	\N	\N	\N	\N	\N	\N	\N	\N	t	XL / White	XL / White	\N	\N
iitem_01KSCR9EC1HSBCQ0QMXEN4Y7A9	2026-05-24 12:25:31.01+02	2026-05-24 12:25:31.01+02	\N	SWEATSHIRT-S	\N	\N	\N	\N	\N	\N	\N	\N	t	S	S	\N	\N
iitem_01KSCR9EC19VPAMPAK41R1AX86	2026-05-24 12:25:31.01+02	2026-05-24 12:25:31.01+02	\N	SWEATSHIRT-M	\N	\N	\N	\N	\N	\N	\N	\N	t	M	M	\N	\N
iitem_01KSCR9EC1R6QJAGR69RNSMBJ1	2026-05-24 12:25:31.01+02	2026-05-24 12:25:31.01+02	\N	SWEATSHIRT-L	\N	\N	\N	\N	\N	\N	\N	\N	t	L	L	\N	\N
iitem_01KSCR9EC1D0M5XFY3BQ62XBSV	2026-05-24 12:25:31.01+02	2026-05-24 12:25:31.01+02	\N	SWEATSHIRT-XL	\N	\N	\N	\N	\N	\N	\N	\N	t	XL	XL	\N	\N
iitem_01KSCR9EC19HVS03GFEAGTK8GE	2026-05-24 12:25:31.01+02	2026-05-24 12:25:31.01+02	\N	SWEATPANTS-S	\N	\N	\N	\N	\N	\N	\N	\N	t	S	S	\N	\N
iitem_01KSCR9EC1Y6XET4SWJZTD8A51	2026-05-24 12:25:31.01+02	2026-05-24 12:25:31.01+02	\N	SWEATPANTS-M	\N	\N	\N	\N	\N	\N	\N	\N	t	M	M	\N	\N
iitem_01KSCR9EC19RHJJ2JFRZ6MPYC5	2026-05-24 12:25:31.01+02	2026-05-24 12:25:31.01+02	\N	SWEATPANTS-L	\N	\N	\N	\N	\N	\N	\N	\N	t	L	L	\N	\N
iitem_01KSCR9EC1V12YZ884F88NY22W	2026-05-24 12:25:31.01+02	2026-05-24 12:25:31.01+02	\N	SWEATPANTS-XL	\N	\N	\N	\N	\N	\N	\N	\N	t	XL	XL	\N	\N
iitem_01KSCR9EC1XRJ5M4ZFVCTDPSBY	2026-05-24 12:25:31.01+02	2026-05-24 12:25:31.01+02	\N	SHORTS-S	\N	\N	\N	\N	\N	\N	\N	\N	t	S	S	\N	\N
iitem_01KSCR9EC166N0FB3G0HQ0PVBJ	2026-05-24 12:25:31.01+02	2026-05-24 12:25:31.01+02	\N	SHORTS-M	\N	\N	\N	\N	\N	\N	\N	\N	t	M	M	\N	\N
iitem_01KSCR9EC1B45Y7RQ5WT4VHDCX	2026-05-24 12:25:31.01+02	2026-05-24 12:25:31.01+02	\N	SHORTS-L	\N	\N	\N	\N	\N	\N	\N	\N	t	L	L	\N	\N
iitem_01KSCR9EC1KZA0Y28HQF7XS00J	2026-05-24 12:25:31.01+02	2026-05-24 12:25:31.01+02	\N	SHORTS-XL	\N	\N	\N	\N	\N	\N	\N	\N	t	XL	XL	\N	\N
iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	2026-05-24 18:52:40.227+02	2026-05-24 18:52:40.227+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Rouge	Rouge	\N	\N
iitem_01KSDEEB53H2NY8JN5MZ4NZBX4	2026-05-24 18:52:40.228+02	2026-05-24 18:52:40.228+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	noir	noir	\N	\N
iitem_01KSH2A90AXJP1WGVK31SDGQ0C	2026-05-26 04:37:41.77+02	2026-05-26 04:37:41.77+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Default variant	Default variant	\N	\N
iitem_01KT156V2D9BDG54AYY9EGRDTX	2026-06-01 10:36:05.839+02	2026-06-01 10:36:05.839+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Noir / 39	Noir / 39	\N	\N
iitem_01KT156V2ESTBNPRTZCNJCE1YK	2026-06-01 10:36:05.839+02	2026-06-01 10:36:05.839+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Noir / 37	Noir / 37	\N	\N
iitem_01KT156V2EC7S24TG3RN8VRQ3Q	2026-06-01 10:36:05.839+02	2026-06-01 10:36:05.839+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Noir / 36	Noir / 36	\N	\N
iitem_01KT156V2EXS7RRW8FEFBXP4ZC	2026-06-01 10:36:05.839+02	2026-06-01 10:36:05.839+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Noir / 35	Noir / 35	\N	\N
iitem_01KT156V2E8YRFAZ8CZMNENNRH	2026-06-01 10:36:05.839+02	2026-06-01 10:36:05.839+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Blue / 39	Blue / 39	\N	\N
iitem_01KT156V2EXY4QQ2R4KG9EBAPC	2026-06-01 10:36:05.839+02	2026-06-01 10:36:05.839+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Blue / 37	Blue / 37	\N	\N
iitem_01KT156V2EKDZX0SXDVKPWFSHQ	2026-06-01 10:36:05.839+02	2026-06-01 10:36:05.839+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Blue / 36	Blue / 36	\N	\N
iitem_01KT156V2EVHR7QXFSPK6RY4YV	2026-06-01 10:36:05.839+02	2026-06-01 10:36:05.839+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Blue / 35	Blue / 35	\N	\N
iitem_01KT156V2E7PC7RQDA6B8FWM85	2026-06-01 10:36:05.839+02	2026-06-01 10:36:05.839+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	vert / 39	vert / 39	\N	\N
iitem_01KT156V2EKD9ESXV7R28GXCAS	2026-06-01 10:36:05.839+02	2026-06-01 10:36:05.839+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	vert / 37	vert / 37	\N	\N
iitem_01KT156V2EX8VC55F19CTQAXS7	2026-06-01 10:36:05.839+02	2026-06-01 10:36:05.839+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	vert / 36	vert / 36	\N	\N
iitem_01KT156V2E1837VDVNJP7FPRT0	2026-06-01 10:36:05.839+02	2026-06-01 10:36:05.839+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	vert / 35	vert / 35	\N	\N
iitem_01KV5D7S8NVB2A9Z0KYW0E88BB	2026-06-15 12:29:04.917+02	2026-06-15 12:29:04.917+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Rouge	Rouge	\N	\N
iitem_01KV5D7S8NAANSQE6PWP50PFRD	2026-06-15 12:29:04.918+02	2026-06-15 12:29:04.918+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Vert	Vert	\N	\N
iitem_01KV5D7S8NTWY0KMPEE92AJJDY	2026-06-15 12:29:04.918+02	2026-06-15 12:29:04.918+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Noire	Noire	\N	\N
iitem_01KV5DPWSPTST7FXX39EXJRFF0	2026-06-15 12:37:20.054+02	2026-06-15 12:37:20.054+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Default variant	Default variant	\N	\N
iitem_01KV5DWPPMJZPADJJEVDXN4WVJ	2026-06-15 12:40:30.42+02	2026-06-15 12:40:30.42+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Default variant	Default variant	\N	\N
iitem_01KV5E6037BBN8QYW3D413M04V	2026-06-15 12:45:34.952+02	2026-06-15 12:45:34.952+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Default variant	Default variant	\N	\N
iitem_01KV5H8J354V8SCWQZ6YKFFKRE	2026-06-15 13:39:24.645+02	2026-06-15 13:39:24.645+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Default variant	Default variant	\N	\N
iitem_01KV5K1Y8CXCPK0QCBM7EJD12F	2026-06-15 14:10:44.876+02	2026-06-15 14:10:44.876+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Rouge	Rouge	\N	\N
iitem_01KV5K1Y8C7Z9E7KPDYKTVSXCT	2026-06-15 14:10:44.876+02	2026-06-15 14:10:44.876+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Vert	Vert	\N	\N
iitem_01KV5K1Y8C1YHWAF1KDMADDJFP	2026-06-15 14:10:44.876+02	2026-06-15 14:10:44.876+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Noire	Noire	\N	\N
iitem_01KVAHVT37TKMYG16FDY59N069	2026-06-17 12:26:07.593+02	2026-06-17 12:26:07.593+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	36 / Rouge	36 / Rouge	\N	\N
iitem_01KVAHVT374ZMFAHPT202HD53G	2026-06-17 12:26:07.593+02	2026-06-17 12:26:07.593+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	36 / Noir	36 / Noir	\N	\N
iitem_01KVAHVT37SFJRAPFHZQPJJ5GA	2026-06-17 12:26:07.593+02	2026-06-17 12:26:07.593+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	36 / Rose	36 / Rose	\N	\N
iitem_01KVAHVT37BDF49THXG5DZSX7M	2026-06-17 12:26:07.593+02	2026-06-17 12:26:07.593+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	37 / Rouge	37 / Rouge	\N	\N
iitem_01KVAHVT375Q8HN5BBDTX5C71B	2026-06-17 12:26:07.593+02	2026-06-17 12:26:07.593+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	37 / Noir	37 / Noir	\N	\N
iitem_01KVAHVT3744EGEW6G5DSZDBJ9	2026-06-17 12:26:07.593+02	2026-06-17 12:26:07.593+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	37 / Rose	37 / Rose	\N	\N
iitem_01KVAHVT38NFKZY1X85C0VYZSD	2026-06-17 12:26:07.593+02	2026-06-17 12:26:07.593+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	38 / Rouge	38 / Rouge	\N	\N
iitem_01KVAHVT38ZCG81XQ3H5KEHA0V	2026-06-17 12:26:07.593+02	2026-06-17 12:26:07.593+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	38 / Noir	38 / Noir	\N	\N
iitem_01KVAHVT38WBN8M5J7YY3Y4P7E	2026-06-17 12:26:07.593+02	2026-06-17 12:26:07.593+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	38 / Rose	38 / Rose	\N	\N
iitem_01KVAHVT38K5CQG715E85GQHW1	2026-06-17 12:26:07.593+02	2026-06-17 12:26:07.593+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	39 / Rouge	39 / Rouge	\N	\N
iitem_01KVAHVT38256GPWHFJF7KKT3G	2026-06-17 12:26:07.593+02	2026-06-17 12:26:07.593+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	39 / Noir	39 / Noir	\N	\N
iitem_01KVAHVT38NJ00QJ8GMJVKJAG2	2026-06-17 12:26:07.593+02	2026-06-17 12:26:07.593+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	39 / Rose	39 / Rose	\N	\N
iitem_01KVAHVT38GAV7S0XRX4E2D380	2026-06-17 12:26:07.593+02	2026-06-17 12:26:07.593+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	40 / Rouge	40 / Rouge	\N	\N
iitem_01KVAHVT38SWM4E7PVNTXZWT5P	2026-06-17 12:26:07.593+02	2026-06-17 12:26:07.593+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	40 / Noir	40 / Noir	\N	\N
iitem_01KVAHVT3898CBHZBCQ0MPR26R	2026-06-17 12:26:07.593+02	2026-06-17 12:26:07.593+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	40 / Rose	40 / Rose	\N	\N
iitem_01KVAHVT38X0SVH0WF33CRPXG6	2026-06-17 12:26:07.593+02	2026-06-17 12:26:07.593+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	41 / Rouge	41 / Rouge	\N	\N
iitem_01KVAHVT382SRSCR7DMZRZVJ5D	2026-06-17 12:26:07.593+02	2026-06-17 12:26:07.593+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	41 / Noir	41 / Noir	\N	\N
iitem_01KVAHVT38WDH8XQM2W8K050NM	2026-06-17 12:26:07.593+02	2026-06-17 12:26:07.593+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	41 / Rose	41 / Rose	\N	\N
iitem_01KVAHVT38WVAJH847VHE24N33	2026-06-17 12:26:07.593+02	2026-06-17 12:26:07.593+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	42 / Rouge	42 / Rouge	\N	\N
iitem_01KVAHVT38G2JSD9BP22ZF4JY7	2026-06-17 12:26:07.593+02	2026-06-17 12:26:07.593+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	42 / Noir	42 / Noir	\N	\N
iitem_01KVAHVT39H53C00SFZRERAJF8	2026-06-17 12:26:07.593+02	2026-06-17 12:26:07.593+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	42 / Rose	42 / Rose	\N	\N
iitem_01KVANBHZZK8M0CGKMSY29DN4N	2026-06-17 13:27:09.311+02	2026-06-17 13:27:09.311+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Default variant	Default variant	\N	\N
iitem_01KWT4YC194V5VY2BDXKX4RB53	2026-07-06 00:03:52.746+02	2026-07-06 04:22:16.24+02	2026-07-06 04:22:16.24+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	36	36	\N	\N
iitem_01KWT4YC196BA6Y9YSTR65BNMQ	2026-07-06 00:03:52.747+02	2026-07-06 04:22:16.244+02	2026-07-06 04:22:16.24+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	37	37	\N	\N
iitem_01KWT4YC198NW967WS87CJ00ZP	2026-07-06 00:03:52.747+02	2026-07-06 04:22:16.246+02	2026-07-06 04:22:16.24+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	38	38	\N	\N
iitem_01KWT4YC19JZ4236W1BZ275EYY	2026-07-06 00:03:52.747+02	2026-07-06 04:22:16.248+02	2026-07-06 04:22:16.24+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	39	39	\N	\N
iitem_01KWT4YC192WYH9RA7ZNNTK11F	2026-07-06 00:03:52.747+02	2026-07-06 04:22:16.249+02	2026-07-06 04:22:16.24+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	40	40	\N	\N
iitem_01KWTKZBP95E8ZW505Y83TMT5K	2026-07-06 04:26:33.801+02	2026-07-06 04:26:33.802+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	36	36	\N	\N
iitem_01KWTKZBP978S4H4NS162WJTKP	2026-07-06 04:26:33.802+02	2026-07-06 04:26:33.802+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	37	37	\N	\N
iitem_01KWTKZBP90TH06VGPXFRVR0WF	2026-07-06 04:26:33.802+02	2026-07-06 04:26:33.802+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	38	38	\N	\N
\.


--
-- Data for Name: inventory_level; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inventory_level (id, created_at, updated_at, deleted_at, inventory_item_id, location_id, stocked_quantity, reserved_quantity, incoming_quantity, metadata, raw_stocked_quantity, raw_reserved_quantity, raw_incoming_quantity) FROM stdin;
ilev_01KSCR9EE4HB0XCRJ8SMSNZDD3	2026-05-24 12:25:31.077+02	2026-05-24 12:25:31.077+02	\N	iitem_01KSCR9EC0PDSZC7VWWAAGC01V	sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KSCR9EE47E91TZ7V5AR4330X	2026-05-24 12:25:31.077+02	2026-05-24 12:25:31.077+02	\N	iitem_01KSCR9EC120WWXK3AG603G67K	sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KSCR9EE4EVJN9EJ69SBDCAFA	2026-05-24 12:25:31.077+02	2026-05-24 12:25:31.077+02	\N	iitem_01KSCR9EC166N0FB3G0HQ0PVBJ	sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KSCR9EE4XS5EG47B95JJFSAN	2026-05-24 12:25:31.077+02	2026-05-24 12:25:31.077+02	\N	iitem_01KSCR9EC17E675WBKDD899K3M	sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KSCR9EE4P6AV9QN5Y4GEKWTM	2026-05-24 12:25:31.077+02	2026-05-24 12:25:31.077+02	\N	iitem_01KSCR9EC19HVS03GFEAGTK8GE	sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KSCR9EE492VZFBFTNX3D13HY	2026-05-24 12:25:31.077+02	2026-05-24 12:25:31.077+02	\N	iitem_01KSCR9EC19RHJJ2JFRZ6MPYC5	sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KSCR9EE4BK7ZGADX1T0K12KS	2026-05-24 12:25:31.077+02	2026-05-24 12:25:31.077+02	\N	iitem_01KSCR9EC19VPAMPAK41R1AX86	sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KSCR9EE4JXPMWJQW6XHQPWAD	2026-05-24 12:25:31.077+02	2026-05-24 12:25:31.077+02	\N	iitem_01KSCR9EC1B45Y7RQ5WT4VHDCX	sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KSCR9EE43YVY5ZA3YSHK1S33	2026-05-24 12:25:31.077+02	2026-05-24 12:25:31.077+02	\N	iitem_01KSCR9EC1C7TWEQCB8E7ANMF8	sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KSCR9EE4M3GNQW6BXT3D73J3	2026-05-24 12:25:31.077+02	2026-05-24 12:25:31.077+02	\N	iitem_01KSCR9EC1D0M5XFY3BQ62XBSV	sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KSCR9EE4HMZNYZC2PG0FVZZD	2026-05-24 12:25:31.077+02	2026-05-24 12:25:31.077+02	\N	iitem_01KSCR9EC1FD0YB5N181ZEN081	sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KSCR9EE4SV9GCDWDKBKMF8YX	2026-05-24 12:25:31.077+02	2026-05-24 12:25:31.077+02	\N	iitem_01KSCR9EC1HB8C05V1RH1RQR94	sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KSCR9EE4CF53X8TCJ1DRV12S	2026-05-24 12:25:31.077+02	2026-05-24 12:25:31.077+02	\N	iitem_01KSCR9EC1HSBCQ0QMXEN4Y7A9	sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KSCR9EE46PH98B4WEQ6E2689	2026-05-24 12:25:31.077+02	2026-05-24 12:25:31.077+02	\N	iitem_01KSCR9EC1KZA0Y28HQF7XS00J	sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KSCR9EE4JV8DJG9SQTNBQXTC	2026-05-24 12:25:31.077+02	2026-05-24 12:25:31.077+02	\N	iitem_01KSCR9EC1R6QJAGR69RNSMBJ1	sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KSCR9EE5VMDX3PBT8JVZJT07	2026-05-24 12:25:31.077+02	2026-05-24 12:25:31.077+02	\N	iitem_01KSCR9EC1V12YZ884F88NY22W	sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KSCR9EE54X0AWBK3WE0487SZ	2026-05-24 12:25:31.077+02	2026-05-24 12:25:31.077+02	\N	iitem_01KSCR9EC1XRJ5M4ZFVCTDPSBY	sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KSCR9EE55NZ9VYVDX5HVZNTC	2026-05-24 12:25:31.077+02	2026-05-24 12:25:31.077+02	\N	iitem_01KSCR9EC1Y0GE50A6RKZ6Q7RP	sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KSCR9EE5HJX63WGST3WQE9TZ	2026-05-24 12:25:31.077+02	2026-05-24 12:25:31.077+02	\N	iitem_01KSCR9EC1Y6XET4SWJZTD8A51	sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KSCR9EE5E4A239Y7SFTX2T63	2026-05-24 12:25:31.077+02	2026-05-24 12:25:31.077+02	\N	iitem_01KSCR9EC1ZGRZB2CBZENPWJC4	sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KV5DAB1JEA2WYPMMNHG3Y2C3	2026-06-15 12:30:28.658+02	2026-06-15 12:30:28.658+02	\N	iitem_01KV5D7S8NAANSQE6PWP50PFRD	sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	-10	0	0	\N	{"value": "-10", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KV5HCBA2CQ14ZMNJK5T466EH	2026-06-15 13:41:28.77+02	2026-06-15 13:41:55.768+02	\N	iitem_01KV5H8J354V8SCWQZ6YKFFKRE	sloc_01KV5E2Y7H26Q6TEM5QXJEXXX6	110	0	0	\N	{"value": "110", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KV5K1YFM8C1MVZZF16GR0HTV	2026-06-15 14:10:45.108+02	2026-06-15 14:10:45.108+02	\N	iitem_01KV5K1Y8C7Z9E7KPDYKTVSXCT	sloc_01KV5E2Y7H26Q6TEM5QXJEXXX6	90	0	0	\N	{"value": "90", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KV5K1YKFG8936SAYE1SFNBWA	2026-06-15 14:10:45.231+02	2026-06-15 14:10:45.231+02	\N	iitem_01KV5K1Y8CXCPK0QCBM7EJD12F	sloc_01KV5E2Y7H26Q6TEM5QXJEXXX6	10	0	0	\N	{"value": "10", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KV5K1YQ9A7E02EFWJ0QFDAFZ	2026-06-15 14:10:45.353+02	2026-06-15 14:10:45.353+02	\N	iitem_01KV5K1Y8C1YHWAF1KDMADDJFP	sloc_01KV5E2Y7H26Q6TEM5QXJEXXX6	70	0	0	\N	{"value": "70", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KVAHVT8FJ3AF25JWJPKC4SRR	2026-06-17 12:26:07.759+02	2026-06-17 12:26:07.759+02	\N	iitem_01KVAHVT37TKMYG16FDY59N069	sloc_01KV5E2Y7H26Q6TEM5QXJEXXX6	30	0	0	\N	{"value": "30", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KVAHVTA9H2YKN7J479YGC5F6	2026-06-17 12:26:07.817+02	2026-06-17 12:26:07.817+02	\N	iitem_01KVAHVT37SFJRAPFHZQPJJ5GA	sloc_01KV5E2Y7H26Q6TEM5QXJEXXX6	30	0	0	\N	{"value": "30", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KVAHVTBW9ANW36PFKD1PRVZP	2026-06-17 12:26:07.868+02	2026-06-17 12:26:07.868+02	\N	iitem_01KVAHVT374ZMFAHPT202HD53G	sloc_01KV5E2Y7H26Q6TEM5QXJEXXX6	10	0	0	\N	{"value": "10", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KWTK7BEAWHJVMFYN2YZ4STV6	2026-07-06 04:13:27.115+02	2026-07-06 04:22:16.246+02	2026-07-06 04:22:16.24+02	iitem_01KWT4YC196BA6Y9YSTR65BNMQ	sloc_01KWSMKZKAD8K1XXWV6EJAZD1F	80	0	0	\N	{"value": "80", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KWTKZBV0CWSN1YZ2MW06J956	2026-07-06 04:26:33.952+02	2026-07-06 04:26:33.952+02	\N	iitem_01KWTKZBP95E8ZW505Y83TMT5K	sloc_01KWSMKZKAD8K1XXWV6EJAZD1F	30	0	0	\N	{"value": "30", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KWTKZBXQC35HSE2MM9TWPXPX	2026-07-06 04:26:34.039+02	2026-07-06 04:26:34.039+02	\N	iitem_01KWTKZBP978S4H4NS162WJTKP	sloc_01KWSMKZKAD8K1XXWV6EJAZD1F	330	0	0	\N	{"value": "330", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KWTKZBZQN79T3Y1FD955Q3HF	2026-07-06 04:26:34.103+02	2026-07-06 04:26:34.103+02	\N	iitem_01KWTKZBP90TH06VGPXFRVR0WF	sloc_01KWSMKZKAD8K1XXWV6EJAZD1F	30	0	0	\N	{"value": "30", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01KSF8JESJC2C9NG3QSXH2BFEX	2026-05-25 11:48:32.434+02	2026-08-12 09:53:02.11+02	\N	iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	sloc_01KSF7CHXY413KMNRYZAE8PT2S	95	19	0	\N	{"value": "95", "precision": 20}	{"value": "19", "precision": 20}	{"value": "0", "precision": 20}
\.


--
-- Data for Name: invite; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.invite (id, email, accepted, token, expires_at, metadata, created_at, updated_at, deleted_at) FROM stdin;
invite_01KWWN1ECDEGVFX7ZHB71PQ11R	princelulinda+1@gmail.com	f	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6Imludml0ZV8wMUtXV04xRUNERUdWRlg3WkhCNzFQUTExUiIsImVtYWlsIjoicHJpbmNlbHVsaW5kYSsxQGdtYWlsLmNvbSIsImlhdCI6MTc4MzM3MzEzNiwiZXhwIjoxNzgzNDU5NTM2LCJqdGkiOiI3ZDQyZmQwYi05YWI5LTRiOGEtYTcxZC0wOWQ3N2QwOTA2NmQifQ.IuXufrEXhdvnEqvFbGGq588zbNJMCOZo-LdpH_WnxhQ	2026-07-07 23:25:36.712+02	\N	2026-07-06 23:23:39.536+02	2026-07-06 23:25:36.718+02	\N
\.


--
-- Data for Name: link_module_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.link_module_migrations (id, table_name, link_descriptor, created_at) FROM stdin;
1	cart_payment_collection	{"toModel": "payment_collection", "toModule": "payment", "fromModel": "cart", "fromModule": "cart"}	2026-05-24 12:23:05.332389
2	cart_promotion	{"toModel": "promotions", "toModule": "promotion", "fromModel": "cart", "fromModule": "cart"}	2026-05-24 12:23:05.337075
3	customer_account_holder	{"toModel": "account_holder", "toModule": "payment", "fromModel": "customer", "fromModule": "customer"}	2026-05-24 12:23:05.339719
4	location_fulfillment_provider	{"toModel": "fulfillment_provider", "toModule": "fulfillment", "fromModel": "location", "fromModule": "stock_location"}	2026-05-24 12:23:05.343047
5	location_fulfillment_set	{"toModel": "fulfillment_set", "toModule": "fulfillment", "fromModel": "location", "fromModule": "stock_location"}	2026-05-24 12:23:05.344951
6	order_cart	{"toModel": "cart", "toModule": "cart", "fromModel": "order", "fromModule": "order"}	2026-05-24 12:23:05.346674
7	order_fulfillment	{"toModel": "fulfillments", "toModule": "fulfillment", "fromModel": "order", "fromModule": "order"}	2026-05-24 12:23:05.34833
8	order_payment_collection	{"toModel": "payment_collection", "toModule": "payment", "fromModel": "order", "fromModule": "order"}	2026-05-24 12:23:05.34988
9	order_promotion	{"toModel": "promotions", "toModule": "promotion", "fromModel": "order", "fromModule": "order"}	2026-05-24 12:23:05.351605
10	return_fulfillment	{"toModel": "fulfillments", "toModule": "fulfillment", "fromModel": "return", "fromModule": "order"}	2026-05-24 12:23:05.353649
11	product_sales_channel	{"toModel": "sales_channel", "toModule": "sales_channel", "fromModel": "product", "fromModule": "product"}	2026-05-24 12:23:05.356986
12	product_shipping_profile	{"toModel": "shipping_profile", "toModule": "fulfillment", "fromModel": "product", "fromModule": "product"}	2026-05-24 12:23:05.360381
13	product_variant_inventory_item	{"toModel": "inventory", "toModule": "inventory", "fromModel": "variant", "fromModule": "product"}	2026-05-24 12:23:05.363867
14	product_variant_price_set	{"toModel": "price_set", "toModule": "pricing", "fromModel": "variant", "fromModule": "product"}	2026-05-24 12:23:05.366833
15	publishable_api_key_sales_channel	{"toModel": "sales_channel", "toModule": "sales_channel", "fromModel": "api_key", "fromModule": "api_key"}	2026-05-24 12:23:05.369719
16	region_payment_provider	{"toModel": "payment_provider", "toModule": "payment", "fromModel": "region", "fromModule": "region"}	2026-05-24 12:23:05.372559
17	sales_channel_stock_location	{"toModel": "location", "toModule": "stock_location", "fromModel": "sales_channel", "fromModule": "sales_channel"}	2026-05-24 12:23:05.375668
18	shipping_option_price_set	{"toModel": "price_set", "toModule": "pricing", "fromModel": "shipping_option", "fromModule": "fulfillment"}	2026-05-24 12:23:05.378791
19	user_rbac_role	{"toModel": "rbac_role", "toModule": "rbac", "fromModel": "user", "fromModule": "user"}	2026-05-24 12:23:05.381506
20	marketplace_vendor_order_order	{"toModel": "order", "toModule": "order", "fromModel": "vendor", "fromModule": "marketplace"}	2026-05-24 12:23:05.38396
21	marketplace_vendor_product_product	{"toModel": "product", "toModule": "product", "fromModel": "vendor", "fromModule": "marketplace"}	2026-05-24 12:23:05.386703
43	marketplace_vendor_stock_location_stock_location	{"toModel": "stock_location", "toModule": "stock_location", "fromModel": "vendor", "fromModule": "marketplace"}	2026-05-25 11:25:18.839888
66	marketplace_vendor_promotion_promotion	{"toModel": "promotion", "toModule": "promotion", "fromModel": "vendor", "fromModule": "marketplace"}	2026-05-25 12:07:48.74936
304	delivery_delivery_company_fulfillment_shipping_option	{"toModel": "shipping_option", "toModule": "fulfillment", "fromModel": "delivery_company", "fromModule": "delivery"}	2026-06-05 00:16:52.249855
\.


--
-- Data for Name: locale; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.locale (id, code, name, created_at, updated_at, deleted_at) FROM stdin;
loc_01KTENZ34VR6VX3D7531DHATPH	en-US	English (United States)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34W4V5BAQ114NYVTYG2	en-GB	English (United Kingdom)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34WG2P4VQHQPRGT9G0N	en-AU	English (Australia)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34WRZ35CZ1WKEMQ8T34	en-CA	English (Canada)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34WB4RE2CJHADSM033Z	es-ES	Spanish (Spain)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34WBPC2RX66P7FWQ1VY	es-MX	Spanish (Mexico)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34WKFA5BBQ0HRRNN09A	es-AR	Spanish (Argentina)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34WSV1EKEZHHN4MWQFE	fr-FR	French (France)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34WN2KF3FKFM8X5Y2DM	fr-CA	French (Canada)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34WXS187KSDMACCXJ6V	fr-BE	French (Belgium)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34WEXM59F80XMAN5VS9	de-DE	German (Germany)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34W1EGKRWW9QASAD01B	de-AT	German (Austria)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34WM4NFSTPQR2MW87EB	de-CH	German (Switzerland)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34W096RKYQQ5FAERSN0	it-IT	Italian (Italy)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34W2EV45TVTK8QYCQNT	pt-BR	Portuguese (Brazil)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34WKHRKMGPY21A2250P	pt-PT	Portuguese (Portugal)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34W6PS500E3VJADK5GQ	nl-NL	Dutch (Netherlands)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34WKNAN1J7MF9WTXGTD	nl-BE	Dutch (Belgium)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34WBM6ET7MSSCAV0KNT	da-DK	Danish (Denmark)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34WBGZFSHXACB4B7HHW	sv-SE	Swedish (Sweden)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34W6PVX35NFF2BVGPWA	nb-NO	Norwegian Bokmål (Norway)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34W609FN40JAK7D8WD8	fi-FI	Finnish (Finland)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34WV837YCY2HZAT4K5J	pl-PL	Polish (Poland)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34X15DA8WTE61AW0B7K	lt-LT	Lithuanian (Lithuania)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34XKHPS6JXR1YV0S6GD	cs-CZ	Czech (Czech Republic)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34XYADG3SCKP99Z4NGK	sk-SK	Slovak (Slovakia)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34XVV3Z90R8T2YJFGHN	hu-HU	Hungarian (Hungary)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34X0DWBQKBEXD5G8Q1H	ro-RO	Romanian (Romania)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34XB5FZEM103C6VVCVT	bg-BG	Bulgarian (Bulgaria)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34XSVSP8Z9B3NWQ9GA3	el-GR	Greek (Greece)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34X21QPD0X11ZQKAND8	tr-TR	Turkish (Turkey)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34XTP5J3R1C5ACCMYBJ	ru-RU	Russian (Russia)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34X0QB895EV7CDY16FT	uk-UA	Ukrainian (Ukraine)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34X89CX8J0QRGJ63N5X	ar-SA	Arabic (Saudi Arabia)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34XAH9P5MY31DZ2Q6NT	ar-AE	Arabic (United Arab Emirates)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34XWQBA0YKHMN31V9MG	ar-EG	Arabic (Egypt)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34XCCV07QEJBQB484M1	he-IL	Hebrew (Israel)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34XF3X6690AZ48BFP44	hi-IN	Hindi (India)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34X9Z4JSK5KQVJ27DPY	bn-BD	Bengali (Bangladesh)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34XS7B8M5C205ZKBDJ1	th-TH	Thai (Thailand)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34XJSPC236KM4NSWABM	vi-VN	Vietnamese (Vietnam)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34X8ZEZMJYR0ZR4P8K3	id-ID	Indonesian (Indonesia)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34XQEM12567EWDQJDJN	ms-MY	Malay (Malaysia)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34XTX40B6PZM6DF1WH5	tl-PH	Tagalog (Philippines)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34XE5GZK20RY7H5DN18	zh-CN	Chinese Simplified (China)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34XWPABNBYN3Y43FWJ6	zh-TW	Chinese Traditional (Taiwan)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34XME232XDWWHKW6Z49	zh-HK	Chinese Traditional (Hong Kong)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34X21KMJ7H1G1PB349X	ja-JP	Japanese (Japan)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34Y3EB1QWDRTAMB94XD	ko-KR	Korean (South Korea)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34YEABFRPTYYFXHN8JF	ka-GE	Georgian (Georgia)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
loc_01KTENZ34YHGH9Z2J6RSEG194G	mn-MN	Mongolian (Mongolia)	2026-06-06 16:39:05.374+02	2026-06-06 16:39:05.374+02	\N
\.


--
-- Data for Name: location_fulfillment_provider; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.location_fulfillment_provider (stock_location_id, fulfillment_provider_id, id, created_at, updated_at, deleted_at) FROM stdin;
sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	manual_manual	locfp_01KSCR9E743K884XE1B3A66K59	2026-05-24 12:25:30.852533+02	2026-05-30 15:30:55.177+02	2026-05-30 15:30:55.176+02
sloc_01KSF7CHXY413KMNRYZAE8PT2S	delivery-company-provider_delivery-company-provider	locfp_01KSWJAJ3CA3EZHK292YHWYZ8W	2026-05-30 15:49:07.051456+02	2026-05-30 15:49:07.051456+02	\N
\.


--
-- Data for Name: location_fulfillment_set; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.location_fulfillment_set (stock_location_id, fulfillment_set_id, id, created_at, updated_at, deleted_at) FROM stdin;
sloc_01KSF7CHXY413KMNRYZAE8PT2S	fuset_01KSR2W2CKBZ3D4B3MB4Y2606S	locfs_01KSR2W2DAZJ45DGD9W4M3S7HP	2026-05-28 22:02:05.865701+02	2026-05-28 22:02:05.865701+02	\N
sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	fuset_01KSCR9E7DBG6TWATM3CH2T54A	locfs_01KSCR9E7MV2KQTVCDZB02FQ1P	2026-05-24 12:25:30.867833+02	2026-05-30 15:30:55.171+02	2026-05-30 15:30:55.17+02
sloc_01KSF7CHXY413KMNRYZAE8PT2S	fuset_01KSWJXMT5RA51MF8N6AK4SGNJ	locfs_01KSWJXMTVCR890GYVB9DX1RRY	2026-05-30 15:59:32.443254+02	2026-05-30 15:59:32.443254+02	\N
\.


--
-- Data for Name: loyalty_coupon; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.loyalty_coupon (id, customer_id, promotion_id, code, source, discount_type, discount_value, status, expires_at, redeemed_at, redeemed_order_id, source_ref_id, created_at, updated_at, deleted_at) FROM stdin;
01KZSMC1N6Z0HXKWTY4TY0BRW8	cus_01KZSMC1GNSS9SXPZ2ZX39N7J9	promo_01KZSMC1MKPKD3FQJ759MBCX6D	EM-M1ERBFUG	wheel	percentage	5	issued	2026-08-17 02:01:20.549+02	\N	\N	01KZSMC1MDV0RJZBE6EQ5XKK2N	2026-08-12 02:01:20.55+02	2026-08-12 02:01:20.55+02	\N
01KZSMEY5NZBK8RPPP0B5EH6XZ	cus_01KZSMEY0DNJ1VVM2P3S3T3222	promo_01KZSMEY4VRFZ2AXHA9GMJZBTC	EM-O9X2TFZJ	wheel	percentage	10	issued	2026-08-19 02:02:55.284+02	\N	\N	01KZSMEY4K94AWQ27A51SYGVBB	2026-08-12 02:02:55.285+02	2026-08-12 02:02:55.285+02	\N
01KZTFBR5S9VKTZMZM6XR5E1W7	cus_01KZSMAT6WFYWBGMFDGBSQVMKG	promo_01KZTFBR4ESFK9JXFQ78933ASZ	EM-DV0ZJ3KZ	referral	percentage	10	issued	2026-08-26 09:53:02.384+02	\N	\N	01KZTFB3MFM46WGA0XRKV1R7M4	2026-08-12 09:53:02.393+02	2026-08-12 09:53:02.393+02	\N
01KZTFBR658SADXNPQ4583EFMA	cus_01KZTFASX63451FWPYQZST4A8M	promo_01KZTFBR4WP6PH32FGP5X3T8F4	EM-XRE56ZBF	referral	percentage	10	issued	2026-08-26 09:53:02.401+02	\N	\N	01KZTFB3MFM46WGA0XRKV1R7M4	2026-08-12 09:53:02.405+02	2026-08-12 09:53:02.405+02	\N
01KZYEPWAC5PZFXTEJ5HJSDJXS	cus_01KSR173ECD4A2AJF6H3R1H2J8	promo_01KZYEPW8TW36MNCRVNQZESW9R	EM-NMNFJW5W	wheel	free_shipping	\N	issued	2026-08-20 22:58:36.234+02	\N	\N	01KZYEPW87HHYQHCXZGTF4CB5M	2026-08-13 22:58:36.236+02	2026-08-13 22:58:36.236+02	\N
\.


--
-- Data for Name: loyalty_transaction; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.loyalty_transaction (id, customer_id, type, points_delta, balance_after, description, ref_id, created_at, updated_at, deleted_at) FROM stdin;
01KZSKXT4KX77NFVRF9C2NWZ97	cus_01KWTJDVCJA6KHS6TX3DTG1P1K	checkin	12	12	Daily check-in (day 1)	01KZSKXT47XSBV67W0FYFKTSKC	2026-08-12 01:53:34.099+02	2026-08-12 01:53:34.099+02	\N
01KZSKXT4MR95K8DFGAYCHQ734	cus_01KWTJDVCJA6KHS6TX3DTG1P1K	checkin	12	12	Daily check-in (day 1)	01KZSKXT45QWVH1H89S8JB0MS2	2026-08-12 01:53:34.101+02	2026-08-12 01:53:34.101+02	\N
01KZSMBAGA4QYXBJS2DEGFAHSK	cus_01KZSMAT6WFYWBGMFDGBSQVMKG	checkin	12	12	Daily check-in (day 1)	01KZSMBAG2WXPV28RM93QRFMBS	2026-08-12 02:00:56.842+02	2026-08-12 02:00:56.842+02	\N
01KZSMBJ4QYT9XXBMJQ253B28D	cus_01KZSMAT6WFYWBGMFDGBSQVMKG	wheel_spin	50	62	Wheel prize: 50 pts	01KZSMBJ4F5J3JN4EX3319MSDP	2026-08-12 02:01:04.664+02	2026-08-12 02:01:04.664+02	\N
01KZSMBZDMFHN0KT05T78DGPW1	cus_01KZSMBZ99Z0Q8P5KTCWCBMJ73	wheel_spin	20	20	Wheel prize: 20 pts	01KZSMBZDE8TKF8VK72R61238G	2026-08-12 02:01:18.26+02	2026-08-12 02:01:18.26+02	\N
01KZSMBZNST1QWZ7SXQVRY0S5V	cus_01KZSMBZHQEP9A4XJX4MPZBXC4	wheel_spin	50	50	Wheel prize: 50 pts	01KZSMBZNKQ5A39WHA6F5DA3CM	2026-08-12 02:01:18.521+02	2026-08-12 02:01:18.521+02	\N
01KZSMBZXM97RY338YN764Y0X8	cus_01KZSMBZSJPHZ5M70N0KP35E5G	wheel_spin	20	20	Wheel prize: 20 pts	01KZSMBZXG7FS7KMRYD6P4P9EN	2026-08-12 02:01:18.772+02	2026-08-12 02:01:18.772+02	\N
01KZSMC0D6WV17W940SBQVH7PJ	cus_01KZSMC096Y09WY697T3056N0G	wheel_spin	50	50	Wheel prize: 50 pts	01KZSMC0D1WHRMGF5Z4M23BQM9	2026-08-12 02:01:19.27+02	2026-08-12 02:01:19.27+02	\N
01KZSMC0NFBR0KK7A7YX37DP1R	cus_01KZSMC0H1D16FKPAF1RH2CT27	wheel_spin	20	20	Wheel prize: 20 pts	01KZSMC0N8RDC96ETHYHB1VRNB	2026-08-12 02:01:19.535+02	2026-08-12 02:01:19.535+02	\N
01KZSMC0XQW4V9K9TX84JRQ31X	cus_01KZSMC0SBE2M7VR1R9XBKMQFY	wheel_spin	50	50	Wheel prize: 50 pts	01KZSMC0XKA4K5A3AXSAX0FFN9	2026-08-12 02:01:19.799+02	2026-08-12 02:01:19.799+02	\N
01KZSMC15D9ZM6NT11835YH1PR	cus_01KZSMC11E5Y9F9SDEM99VXJPS	wheel_spin	100	100	Wheel prize: 100 pts	01KZSMC159ZFVGJDSWZCZFNT1N	2026-08-12 02:01:20.045+02	2026-08-12 02:01:20.045+02	\N
01KZSMC26KXY19RNJC26K81DYQ	cus_01KZSMC22GW2AVN7D38GNN414A	wheel_spin	100	100	Wheel prize: 100 pts	01KZSMC26D3CZRJY0308M6YCSZ	2026-08-12 02:01:21.107+02	2026-08-12 02:01:21.107+02	\N
01KZSMEXTXSXKPD0PJ1FVQ0QTC	cus_01KZSMEXNKDNW2N4PS3SQCG84M	wheel_spin	20	20	Wheel prize: 20 pts	01KZSMEXTM5GG4NYQE8K3N0RDJ	2026-08-12 02:02:54.941+02	2026-08-12 02:02:54.941+02	\N
01KZSMYMCM4DD45J1AMBTE32PR	cus_01KSR173ECD4A2AJF6H3R1H2J8	checkin	12	12	Daily check-in (day 1)	01KZSMYMCBA9PQ3QVAEX8ZH74T	2026-08-12 02:11:29.556+02	2026-08-12 02:11:29.556+02	\N
01KZTF1CEAM1EZ2FT4QX6TANN2	cus_01KZTETSA89TK03RE3G06BXQDJ	wheel_spin	100	100	Wheel prize: 100 pts	01KZTF1CDT8BM2P562XP5F6023	2026-08-12 09:47:22.698+02	2026-08-12 09:47:22.698+02	\N
01KZV2S9R5XGETWTRBXJXB3M7N	cus_01KZV2PTYGTZ4E2VCQ7R28NYVF	wheel_spin	20	20	Wheel prize: 20 pts	01KZV2S9QKDEP650Z1F89QXMPD	2026-08-12 15:32:29.317+02	2026-08-12 15:32:29.317+02	\N
01M01CHCGMPZE4XEJ5FHVNBK0M	cus_01KWTHT7FNHAP08HMCSJ9NW4P9	wheel_spin	100	100	Wheel prize: 100 pts	01M01CHCFWVYDBFD5QAC697EPQ	2026-08-15 02:18:22.357+02	2026-08-15 02:18:22.357+02	\N
01M02EPYTH8CFWPZSCP0A2J431	cus_01KVDNF9NVQVFFF9WFB56HN13V	wheel_spin	50	50	Wheel prize: 50 pts	01M02EPYRA1WRXZ4PB2N2W7D92	2026-08-15 12:15:36.53+02	2026-08-15 12:15:36.53+02	\N
01M03DYCQXXHJYC273SHXNW2PN	cus_01KSR173ECD4A2AJF6H3R1H2J8	checkin	12	24	Daily check-in (day 1)	01M03DYCQMMS06G0D9GG0H6NV4	2026-08-15 21:21:26.013+02	2026-08-15 21:21:26.013+02	\N
\.


--
-- Data for Name: marketplace_vendor_order_order; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.marketplace_vendor_order_order (vendor_id, order_id, id, created_at, updated_at, deleted_at) FROM stdin;
01KSDE9JVTNAXE0NF67DNVEWBS	order_01KSWZ94QHBKV096ESCTPKNS2N	link_01KSWZ951BA0X1BTZWH3H3F1F6	2026-05-30 19:35:32.395386+02	2026-05-30 19:35:32.395386+02	\N
01KSDE9JVTNAXE0NF67DNVEWBS	order_01KSYNR3FQYDZ176SCBXMTC2CA	link_01KSYNR3JFZRWMNAVQMEW0EQFH	2026-05-31 11:27:25.519572+02	2026-05-31 11:27:25.519572+02	\N
01KSDE9JVTNAXE0NF67DNVEWBS	order_01KSYPW2RSZ248CCQ1F6HZEQJ5	link_01KSYPW2W9DNM2DQRZMFXG2GND	2026-05-31 11:47:04.457494+02	2026-05-31 11:47:04.457494+02	\N
01KSDE9JVTNAXE0NF67DNVEWBS	order_01KSYZ528J6XCKJY7DR20SPNTZ	link_01KSYZ52CTET0KDTFEWZ6RX2S2	2026-05-31 14:11:47.482427+02	2026-05-31 14:11:47.482427+02	\N
01KSDE9JVTNAXE0NF67DNVEWBS	order_01KSYZ9NKNR0ZFP1NHRRJ6C4H0	link_01KSYZ9NPN1H34AYBF57KNA1TN	2026-05-31 14:14:18.325356+02	2026-05-31 14:14:18.325356+02	\N
01KSDE9JVTNAXE0NF67DNVEWBS	order_01KSYZEHBJT6J0R02PCEWAQXYW	link_01KSYZEHEPR92FQG20ZNP3TS1Z	2026-05-31 14:16:57.814703+02	2026-05-31 14:16:57.814703+02	\N
01KSDE9JVTNAXE0NF67DNVEWBS	order_01KSZ025ATTT8ABSP8NXJK5XXH	link_01KSZ025EXNCNNA7V1AEMMH1B1	2026-05-31 14:27:40.893224+02	2026-05-31 14:27:40.893224+02	\N
01KSDE9JVTNAXE0NF67DNVEWBS	order_01KSZ040QG8CAWV63TQC132B9P	link_01KSZ040V2ZS9G7JGCK0N0GXB9	2026-05-31 14:28:41.698047+02	2026-05-31 14:28:41.698047+02	\N
01KSDE9JVTNAXE0NF67DNVEWBS	order_01KSZ0VB193K4QY97BW6PNNHWE	link_01KSZ0VB4H8T5A4R5PRVTN5A6N	2026-05-31 14:41:25.905211+02	2026-05-31 14:41:25.905211+02	\N
01KSDE9JVTNAXE0NF67DNVEWBS	order_01KZSRKT0QNS81MFMA4G05RZ8E	link_01KZSRKTA47D4FRJNV5E6XVRSH	2026-08-12 03:15:29.47591+02	2026-08-12 03:15:29.47591+02	\N
01KSDE9JVTNAXE0NF67DNVEWBS	order_01KZSRPGT61RWGZEV4XWSST4DB	link_01KZSRPH2MSQFMRYNJ3B1KP614	2026-08-12 03:16:58.324495+02	2026-08-12 03:16:58.324495+02	\N
01KSDE9JVTNAXE0NF67DNVEWBS	order_01KZSRT94K7A6N76KXHBVTJKMJ	link_01KZSRT9CPY77V647XMRYAY2FB	2026-08-12 03:19:01.52597+02	2026-08-12 03:19:01.52597+02	\N
01KSDE9JVTNAXE0NF67DNVEWBS	order_01KZSS4E0E2TDSQ1CZW34GVH80	link_01KZSS4E8C4SZ6RQAWGZWH3VG4	2026-08-12 03:24:34.187921+02	2026-08-12 03:24:34.187921+02	\N
01KSDE9JVTNAXE0NF67DNVEWBS	order_01KZSS713JEJG13A30NW7X2RR7	link_01KZSS71BN80M3NVCD7DFAX4JM	2026-08-12 03:25:59.284795+02	2026-08-12 03:25:59.284795+02	\N
01KSDE9JVTNAXE0NF67DNVEWBS	order_01KZTFBQSNE8M83ECV3F4F3K9J	link_01KZTFBR2DK8RV70THN8AEZSA9	2026-08-12 09:53:02.285306+02	2026-08-12 09:53:02.285306+02	\N
\.


--
-- Data for Name: marketplace_vendor_product_product; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.marketplace_vendor_product_product (vendor_id, product_id, id, created_at, updated_at, deleted_at) FROM stdin;
01KSDE9JVTNAXE0NF67DNVEWBS	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	link_01KSDEEB69GSNW77MTA307205R	2026-05-24 18:52:40.265381+02	2026-05-24 18:52:40.265381+02	\N
01KSCSTSP7N25SPSF2H5AK45FY	prod_01KSH2A8YPQ2M4AN368YBJ9X3C	link_01KSH2A91JR3492ZSN6TJWAQRV	2026-05-26 04:37:41.810297+02	2026-05-26 04:37:41.810297+02	\N
01KSDE9JVTNAXE0NF67DNVEWBS	prod_01KT156V00QYP2NS7HYG4BWMYG	link_01KT156V6MZKDV945WXMDC2ZM4	2026-06-01 10:36:05.971865+02	2026-06-01 10:36:05.971865+02	\N
01KV5CHYWYZVSNYGB0RXEYG5CK	prod_01KV5D7S5A3GT3TNV6JJ36QA88	link_01KV5D7SBVG7RMDN22APX84S2G	2026-06-15 12:29:05.019384+02	2026-06-15 12:29:05.019384+02	\N
01KV5CHYWYZVSNYGB0RXEYG5CK	prod_01KV5DPWQMJ87E724G2PHS05ZZ	link_01KV5DPWV0V2X85CRQHXPS0095	2026-06-15 12:37:20.095416+02	2026-06-15 12:37:20.095416+02	\N
01KV5CHYWYZVSNYGB0RXEYG5CK	prod_01KV5DWPN1992BC1RARAP2H0K1	link_01KV5DWPRRB5N25RB4K7GA0GFF	2026-06-15 12:40:30.488409+02	2026-06-15 12:40:30.488409+02	\N
01KV5CHYWYZVSNYGB0RXEYG5CK	prod_01KV5E601185BKG901X7QG2CEW	link_01KV5E604ZF1Q3Z1T1A7XQF2SP	2026-06-15 12:45:35.00724+02	2026-06-15 12:45:35.00724+02	\N
01KV5CHYWYZVSNYGB0RXEYG5CK	prod_01KV5H8J0X1ZXZA46EZ0MG683D	link_01KV5H8J4RFRTA73QYC1RRD8H2	2026-06-15 13:39:24.696104+02	2026-06-15 13:39:24.696104+02	\N
01KV5CHYWYZVSNYGB0RXEYG5CK	prod_01KV5K1Y66BRSD3K4GDMN4M1YS	link_01KV5K1YATFMASZPYWKZ5N2459	2026-06-15 14:10:44.953439+02	2026-06-15 14:10:44.953439+02	\N
01KV5CHYWYZVSNYGB0RXEYG5CK	prod_01KVAHVT1115P37Z781SCQWX1W	link_01KVAHVT5N2W0FWCVPENF0039E	2026-06-17 12:26:07.669789+02	2026-06-17 12:26:07.669789+02	\N
01KV5CHYWYZVSNYGB0RXEYG5CK	prod_01KVANBHYVPHYHTH3VKVZDF1VJ	link_01KVANBJ0TRAX7XQS838BY5K7N	2026-06-17 13:27:09.338731+02	2026-06-17 13:27:09.338731+02	\N
01KWSMG9MENSKS30A5SCWX8JW2	prod_01KWT4YBXAFKGSHX0R820VDJS4	link_01KWT4YC53E97W714WRNZ63X83	2026-07-06 00:03:52.867345+02	2026-07-06 04:22:16.279+02	2026-07-06 04:22:16.278+02
01KWSMG9MENSKS30A5SCWX8JW2	prod_01KWTKZBN13GNZVP6YNBMAD3VP	link_01KWTKZBQ22XENPX6ECB77E7A0	2026-07-06 04:26:33.826618+02	2026-07-06 04:26:33.826618+02	\N
\.


--
-- Data for Name: marketplace_vendor_promotion_promotion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.marketplace_vendor_promotion_promotion (vendor_id, promotion_id, id, created_at, updated_at, deleted_at) FROM stdin;
01KSDE9JVTNAXE0NF67DNVEWBS	promo_01KSFTYA07BW0AWQY1MGK5YPZ2	link_01KSFTYA1Y5BPQC490F9EZM19M	2026-05-25 17:09:35.166018+02	2026-05-25 17:09:35.166018+02	\N
01KSCSTSP7N25SPSF2H5AK45FY	promo_01KSSPF5WN97JJ7DAEWAWW9TQJ	link_01KSSPF5XHQJCN7PCE7FB7N5BA	2026-05-29 13:03:49.425618+02	2026-05-29 13:03:49.425618+02	\N
\.


--
-- Data for Name: marketplace_vendor_stock_location_stock_location; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.marketplace_vendor_stock_location_stock_location (vendor_id, stock_location_id, id, created_at, updated_at, deleted_at) FROM stdin;
01KSDE9JVTNAXE0NF67DNVEWBS	sloc_01KSF7CHXY413KMNRYZAE8PT2S	link_01KSF7CHYG372Y9YY98H6C3DHR	2026-05-25 11:27:50.480123+02	2026-05-25 11:27:50.480123+02	\N
01KV57JBZBPRJ93AM3PSKFTMMH	sloc_01KV57VMM76EG8GT7Q0K6YJWNY	link_01KV57VMMR5Y96JGFBTSV9EEN6	2026-06-15 10:55:04.087806+02	2026-06-15 10:55:04.087806+02	\N
01KV5CHYWYZVSNYGB0RXEYG5CK	sloc_01KV5E2Y7H26Q6TEM5QXJEXXX6	link_01KV5E2Y85VY54K03VHMA4GE3R	2026-06-15 12:43:54.756949+02	2026-06-15 12:43:54.756949+02	\N
01KV69YB45Q6QNDRG5VPA4X643	sloc_01KV6A8VK5MQZ5M0VNTGGF1EZ4	link_01KV6A8VKT650PMVNV4Z47QTDB	2026-06-15 20:56:28.79392+02	2026-06-15 20:56:28.79392+02	\N
01KWSMG9MENSKS30A5SCWX8JW2	sloc_01KWSMKZKAD8K1XXWV6EJAZD1F	link_01KWSMKZKTWGQ544A3GPYKBX4X	2026-07-05 19:18:35.129614+02	2026-07-05 19:18:35.129614+02	\N
\.


--
-- Data for Name: message; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.message (id, conversation_id, sender_type, sender_id, content, type, file_url, is_read, created_at, updated_at, deleted_at, reactions, delivered_at, reply_to_id, metadata) FROM stdin;
01KSDJSN83YY52QZ0QNYN318RG	01KSDJSH13J278RNCTA18TBV4D	customer	cus_01KSDGQE4N7DEJ0C3Q810Y8CYP	What is the price?	text	\N	f	2026-05-24 20:08:45.315+02	2026-05-24 20:08:45.315+02	\N	\N	\N	\N	\N
01KSDK3RHSGNAYVCWJR3AEPQQS	01KSDJSH13J278RNCTA18TBV4D	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Bonjour	text	\N	f	2026-05-24 20:14:16.377+02	2026-05-24 20:14:16.377+02	\N	\N	\N	\N	\N
01KSDK5MRGCZBPDKCGSWD5ZY8H	01KSDJSH13J278RNCTA18TBV4D	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Maman	text	\N	f	2026-05-24 20:15:18.032+02	2026-05-24 20:15:18.032+02	\N	\N	\N	\N	\N
01KSDKAH6MCDSQ31TE2NVVR3TZ	01KSDJSH13J278RNCTA18TBV4D	customer	cus_01KSDGQE4N7DEJ0C3Q810Y8CYP	Is it available?	text	\N	f	2026-05-24 20:17:58.228+02	2026-05-24 20:17:58.228+02	\N	\N	\N	\N	\N
01KSDKB5KA3JQKPB7118CPYJBZ	01KSDJSH13J278RNCTA18TBV4D	customer	cus_01KSDGQE4N7DEJ0C3Q810Y8CYP		image	http://localhost:9000/static/1779646696595-image.jpg	f	2026-05-24 20:18:19.114+02	2026-05-24 20:18:19.114+02	\N	\N	\N	\N	\N
01KSF05ZH3M0D7Z6PTVGQQFCD2	01KSDJSH13J278RNCTA18TBV4D	customer	cus_01KSDGQE4N7DEJ0C3Q810Y8CYP	📦 Ma saani - 10000 EUR	image	http://localhost:9000/static/1779641482219-image.jpg	f	2026-05-25 09:21:54.979+02	2026-05-25 09:21:54.979+02	\N	\N	\N	\N	\N
01KSF09GTQ3Z7GRAAVRCY5Z0TZ	01KSDJSH13J278RNCTA18TBV4D	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Image	image	http://localhost:9000/static/1779693826275-image.jpg	f	2026-05-25 09:23:50.999+02	2026-05-25 09:23:50.999+02	\N	\N	\N	\N	\N
01KT0AXPJ8NFQEHHVZZ81VQ4WJ	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour, est-ce disponible ?	text	\N	t	2026-06-01 02:56:43.337+02	2026-06-01 03:00:15.678+02	\N	\N	\N	\N	\N
01KT0B05KSAFT9QX0BBSFR4PZJ	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Quel est le meilleur prix ?	text	\N	t	2026-06-01 02:58:04.282+02	2026-06-01 03:00:15.683+02	\N	\N	\N	\N	\N
01KSSPBJV91ZD1RMBT7WZ9TRH1	01KSRC31WGAE8QWZC9PM6RMS3Y	vendor	01KSCSTSP7N25SPSF2H5AK45FY	C'est 1000 USD	text	\N	t	2026-05-29 13:01:51.593+02	2026-06-01 03:07:02.399+02	\N	\N	\N	\N	\N
01KT0CRGAQ508803TPYZ2JN2MW	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Bonjour	image	http://localhost:9000/static/1780277325311-image.jpg	t	2026-06-01 03:28:50.263+02	2026-06-01 03:28:51.548+02	\N	\N	\N	\N	\N
01KT0DH51TNFCM46FY4D8706C8	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Quel est le meilleur prix ?	file	http://localhost:9000/static/1780278131707-1000020362.mp4	t	2026-06-01 03:42:17.914+02	2026-06-01 03:42:18.005+02	\N	\N	\N	\N	\N
01KT0DJBM349338AVWE2S3TKZ1	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8		image	http://localhost:9000/static/1780278173341-1000020644.jpg	t	2026-06-01 03:42:57.411+02	2026-06-01 03:42:57.865+02	\N	\N	\N	\N	\N
01KSZ1FBS229AZ0XDBSBME1JT1	01KSDJSH13J278RNCTA18TBV4D	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Je	text	\N	f	2026-05-31 14:52:21.923+02	2026-05-31 14:52:21.923+02	\N	\N	\N	\N	\N
01KSZCB0TS0PRHBR5QEY4YQCEE	01KSZCADYC4Z7KN64BXJ5023R1	customer	cus_01KSVPWBFY9T5MZXK47CYD788Q	Bonjour, est-ce disponible ?	text	\N	t	2026-05-31 18:02:13.978+02	2026-06-01 04:07:56.33+02	\N	\N	\N	\N	\N
01KT13RKJR53CG2V42NKYKNXS9	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Bb	text	\N	t	2026-06-01 10:10:50.841+02	2026-06-01 12:50:26.021+02	\N	\N	\N	\N	\N
01KT1DGQ1PEB185BR7ZRHKN9W7	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Hhhh	text	\N	t	2026-06-01 13:01:18.006+02	2026-06-01 13:01:43.868+02	\N	\N	\N	\N	\N
01KTFXC30WGX1KSHC1BMWC7HG6	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bo	text	\N	f	2026-06-07 04:07:45.693+02	2026-06-07 04:07:45.693+02	\N	\N	\N	\N	\N
01KTFXGTRZ58D5GGZBN4JJHTH9	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour	text	\N	f	2026-06-07 04:10:21.087+02	2026-06-07 04:10:21.087+02	\N	\N	\N	\N	\N
01KSSP8HWA4JV2KK5T98QZ6C99	01KSRC31WGAE8QWZC9PM6RMS3Y	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	C'est combien\n\n📦 Sufuria - 10000 EUR	image	http://localhost:9000/static/1779763040657-image.jpg	f	2026-05-29 13:00:12.298+02	2026-05-31 17:00:43.615+02	2026-05-31 17:00:43.614+02	\N	\N	\N	\N
01KSSP6A4W7NGVTMNBF490MVB9	01KSRC31WGAE8QWZC9PM6RMS3Y	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	What is the price?	text	\N	f	2026-05-29 12:58:58.844+02	2026-05-31 17:00:48.207+02	2026-05-31 17:00:48.206+02	\N	\N	\N	\N
01KSS3EHV2FX6944K0YMTJT5E7	01KSRC31WGAE8QWZC9PM6RMS3Y	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	What is the price?\n\n📦 Sufuria - 10000 EUR	image	http://localhost:9000/static/1779763040657-image.jpg	f	2026-05-29 07:31:25.922+02	2026-05-31 17:00:57.014+02	2026-05-31 17:00:57.014+02	\N	\N	\N	\N
01KSZBMBKZVY9KNQK8F4CAJSMN	01KSZBM4SAZPVEQAZMQZFZ5NXG	customer	cus_01KSWS7V39C4SDB1YTY9K83SMS	Bonjour, est-ce disponible ?	text	\N	f	2026-05-31 17:49:51.359+02	2026-05-31 17:49:51.359+02	\N	\N	\N	\N	\N
01KSZ8B41YXP82YJBPZGFDVH7S	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Hhhhhj	text	\N	t	2026-05-31 16:52:22.975+02	2026-06-01 01:36:17.049+02	\N	\N	\N	\N	\N
01KSZ8DGB6686Q8TDE9H82WFJ1	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	💡 Conseil pratique pour les langues africaines :\nIl est souvent préférable de créer ton propre dataset, car la plupart des datasets open-source ne contiennent pas assez de données pour ces langues.\nMême 5 à 10 heures de voix bien nettoyées peuvent donner un TTS de base correct.\nSi tu veux, je peux te �⁠faire un workflow complet étape par étape, �⁠avec tous les outils open-source pour créer un TTS en français africain ou toute langue africaine que tu vises.	text	\N	t	2026-05-31 16:53:41.094+02	2026-06-01 01:36:17.069+02	\N	\N	\N	\N	\N
01KSZBEZH2EEK2405CKH9NPAD0	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Hhhhjjjjjjjjjj	text	\N	t	2026-05-31 17:46:55.138+02	2026-06-01 01:36:17.081+02	\N	\N	\N	\N	\N
01KSYRKX3GJMT0EF5YSP4FS3NY	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Hello	text	\N	t	2026-05-31 12:17:33.552+02	2026-06-01 01:58:27.744+02	\N	\N	\N	\N	\N
01KSZ0WJRMGF991D581GR4224V	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	What is the price?	text	\N	t	2026-05-31 14:42:06.484+02	2026-06-01 01:58:27.746+02	\N	\N	\N	\N	\N
01KSZ11QPW6TNKX796GFT0ZB29	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	What is the price?	text	\N	t	2026-05-31 14:44:55.388+02	2026-06-01 01:58:27.774+02	\N	\N	\N	\N	\N
01KSZ12K60X4GQ456X1CADDRF1	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bon	text	\N	t	2026-05-31 14:45:23.52+02	2026-06-01 01:58:27.775+02	\N	\N	\N	\N	\N
01KSZ8AQ638D9567TMKQK9ZFJ1	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	What is the price?	text	\N	t	2026-05-31 16:52:09.795+02	2026-06-01 01:58:27.777+02	\N	\N	\N	\N	\N
01KSZ8E3SDHTG1REV1K4W6B81E	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	💡 Conseil pratique pour les langues africaines :\nIl est souvent préférable de créer ton propre dataset, car la plupart des datasets open-source ne contiennent pas assez de données pour ces langues.\nMême 5 à 10 heures de voix bien nettoyées peuvent donner un TTS de base correct.\nSi tu veux, je peux te �⁠faire un workflow complet étape par étape, �⁠avec tous les outils open-source pour créer un TTS en français africain ou toute langue africaine que tu vises.	text	\N	t	2026-05-31 16:54:01.005+02	2026-06-01 01:58:27.778+02	\N	\N	\N	\N	\N
01KSZAJ1R4CRD1EKZN3F41CAWZ	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour, est-ce disponible ?	text	\N	t	2026-05-31 17:31:07.14+02	2026-06-01 01:58:27.779+02	\N	\N	\N	\N	\N
01KSZAMMTDVBFJZZV9HN8D3176	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour \nJe ne sais	text	\N	t	2026-05-31 17:32:32.205+02	2026-06-01 01:58:27.782+02	\N	\N	\N	\N	\N
01KSZ1DJPMEGKBF739E2H0P4AZ	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Delivery time?	text	\N	t	2026-05-31 14:51:23.476+02	2026-06-01 01:58:27.788+02	\N	\N	\N	\N	\N
01KSZ13B63GHJEE2MV48JPWM3A	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	What is the price?	text	\N	t	2026-05-31 14:45:48.099+02	2026-06-01 01:58:27.79+02	\N	\N	\N	\N	\N
01KSZANCTEK6JM2RSXTD6WQYBJ	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Nnn	text	\N	t	2026-05-31 17:32:56.782+02	2026-06-01 01:58:27.818+02	\N	\N	\N	\N	\N
01KSZAPGYR5F4MG8VFM339Y4GH	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Combien coûte la livraison ?hh	text	\N	t	2026-05-31 17:33:33.784+02	2026-06-01 01:58:27.827+02	\N	\N	\N	\N	\N
01KSZBN164PE35GHJK5PBDVAKM	01KSZBM4SAZPVEQAZMQZFZ5NXG	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Hello	text	\N	f	2026-05-31 17:50:13.444+02	2026-05-31 17:50:13.444+02	\N	\N	\N	\N	\N
01KSZBQDAK11V64P2TB50HNSFM	01KSZBM4SAZPVEQAZMQZFZ5NXG	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Mmm	text	\N	f	2026-05-31 17:51:31.411+02	2026-05-31 17:51:31.411+02	\N	\N	\N	\N	\N
01KT0B34MZFAQMNS8C2M0AEHS1	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Pouvez-vous m'accorder une remise ?	text	\N	t	2026-06-01 02:59:41.599+02	2026-06-01 03:00:15.682+02	\N	\N	\N	\N	\N
01KT0BDK474D2EKYRPCZXKV2C8	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Kkkk	text	\N	t	2026-06-01 03:05:24.103+02	2026-06-01 03:07:10.458+02	\N	\N	\N	\N	\N
01KSZCCDC16T14CHZBGW39AG38	01KSZCADYC4Z7KN64BXJ5023R1	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Pi	text	\N	t	2026-05-31 18:02:59.585+02	2026-06-01 03:33:13.375+02	\N	\N	\N	\N	\N
01KSZCDSTM4PRXVJKWNAPZSSHT	01KSZCADYC4Z7KN64BXJ5023R1	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Nnnnn	text	\N	t	2026-05-31 18:03:45.108+02	2026-06-01 03:33:13.378+02	\N	\N	\N	\N	\N
01KSZE8M4R11A1HJS747ZD5KPA	01KSZCADYC4Z7KN64BXJ5023R1	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Ooooop	text	\N	t	2026-05-31 18:35:52.601+02	2026-06-01 03:33:13.378+02	\N	\N	\N	\N	\N
01KSZQ5SKTZHMXA52MGTHNVC19	01KSZCADYC4Z7KN64BXJ5023R1	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Hello	text	\N	t	2026-05-31 21:11:37.083+02	2026-06-01 03:33:13.38+02	\N	\N	\N	\N	\N
01KT0D5C4TTSFDRFF5XCM3X0ZC	01KSVVRRD4M51QGFJ12RKZN3V3	customer	cus_01KSVPWBFY9T5MZXK47CYD788Q	Quel est le meilleur prix ?	text	\N	f	2026-06-01 03:35:51.962+02	2026-06-01 03:35:58.121+02	2026-06-01 03:35:58.121+02	\N	\N	\N	\N
01KSZ71V2TQ7AN7MAFJ0Q24SQF	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Hello	text	\N	t	2026-05-31 16:29:50.299+02	2026-06-01 01:36:17.023+02	\N	\N	\N	\N	\N
01KSZ735RBPQPDRXA6FQ108H2Y	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Hello	text	\N	t	2026-05-31 16:30:33.995+02	2026-06-01 01:36:17.032+02	\N	\N	\N	\N	\N
01KSZ76DG9VGPC33TT0QDQKJPC	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Mmmm	text	\N	t	2026-05-31 16:32:20.234+02	2026-06-01 01:36:17.034+02	\N	\N	\N	\N	\N
01KSZ87JB7DD0DKNXFKDPARE2H	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Hé	text	\N	t	2026-05-31 16:50:26.535+02	2026-06-01 01:36:17.036+02	\N	\N	\N	\N	\N
01KSZ892Y893GTFSH8VRC3P8BW	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Jjjjjj	text	\N	t	2026-05-31 16:51:16.298+02	2026-06-01 01:36:17.038+02	\N	\N	\N	\N	\N
01KSZ8FSHM4XBCTMF2GXZEXST9	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	💡 Conseil pratique pour les langues africaines :\nIl est souvent préférable de créer ton propre dataset, car la plupart des datasets open-source ne contiennent pas assez de données pour ces langues.\nMême 5 à 10 heures de voix bien nettoyées peuvent donner un TTS de base correct.\nSi tu veux, je peux te �⁠faire un workflow complet étape par étape, �⁠avec tous les outils open-source pour créer un TTS en français africain ou toute langue africaine que tu vises.	text	\N	t	2026-05-31 16:54:56.053+02	2026-06-01 01:36:17.071+02	\N	\N	\N	\N	\N
01KSZAQRYK7KZ964PDMKH2KSKM	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Bonjour	text	\N	t	2026-05-31 17:34:14.739+02	2026-06-01 01:36:17.073+02	\N	\N	\N	\N	\N
01KSZAYDH0TSQN0ZM75XC1BPPS	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	🙂‍↔️	text	\N	t	2026-05-31 17:37:52.416+02	2026-06-01 01:36:17.075+02	\N	\N	\N	\N	\N
01KT01G83FR8V8Y7VJ9J8DX033	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Oooo	text	\N	t	2026-06-01 00:12:05.359+02	2026-06-01 01:36:17.089+02	\N	\N	\N	\N	\N
01KT02SSG7ASSEQP7BVYNJCQW4	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Nnnn	text	\N	t	2026-06-01 00:34:46.664+02	2026-06-01 01:36:17.092+02	\N	\N	\N	\N	\N
01KT03762XZDEV0HR0M43HNVN5	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Iiii	text	\N	t	2026-06-01 00:42:05.533+02	2026-06-01 01:36:17.098+02	\N	\N	\N	\N	\N
01KT03FQX53M0D8AAKGJ7T51Z5	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Ggg	text	\N	t	2026-06-01 00:46:45.925+02	2026-06-01 01:36:17.101+02	\N	\N	\N	\N	\N
01KSZD4ZJHY2AZDPRM2TTV5JYC	01KSZCADYC4Z7KN64BXJ5023R1	customer	cus_01KSVPWBFY9T5MZXK47CYD788Q	Quel est le meilleur prix ?	text	\N	f	2026-05-31 18:16:24.658+02	2026-06-01 03:36:10.532+02	2026-06-01 03:36:10.532+02	\N	\N	\N	\N
01KSZCVVKQDNR8ZV8J5RQ2S8MQ	01KSZCADYC4Z7KN64BXJ5023R1	customer	cus_01KSVPWBFY9T5MZXK47CYD788Q	Quel est le meilleur prix ?	text	\N	f	2026-05-31 18:11:25.688+02	2026-06-01 03:36:14.689+02	2026-06-01 03:36:14.689+02	\N	\N	\N	\N
01KSZCPYST72W49Q469X76YYR7	01KSZCADYC4Z7KN64BXJ5023R1	customer	cus_01KSVPWBFY9T5MZXK47CYD788Q	Quel est le meilleur prix ?	text	\N	f	2026-05-31 18:08:45.115+02	2026-06-01 03:36:18.421+02	2026-06-01 03:36:18.421+02	\N	\N	\N	\N
01KT06CW47TTCAX85W9HBGM1GB	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Iijjjj	text	\N	t	2026-06-01 01:37:37.672+02	2026-06-01 01:37:37.717+02	\N	\N	\N	\N	\N
01KT06D6W6F5D4R64D3RKR3WQ7	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Jjjnjj	text	\N	t	2026-06-01 01:37:48.679+02	2026-06-01 01:37:49.848+02	\N	\N	\N	\N	\N
01KSZCG5ANG10NR1YX16E8G33V	01KSZCADYC4Z7KN64BXJ5023R1	customer	cus_01KSVPWBFY9T5MZXK47CYD788Q	Quel est le meilleur prix ?	text	\N	t	2026-05-31 18:05:02.421+02	2026-06-01 04:07:56.326+02	\N	\N	\N	\N	\N
01KT06H6VQ0M09VBXVZJGRQ6MA	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Papa	text	\N	t	2026-06-01 01:39:59.735+02	2026-06-01 01:42:50.93+02	\N	\N	\N	\N	\N
01KT071W5N0K7QDXXGR3XRDVD5	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Mama	text	\N	t	2026-06-01 01:49:05.845+02	2026-06-01 01:49:11.884+02	\N	\N	\N	\N	\N
01KSZ1EEHXE87G8T8KRFS8BD1G	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	What is the price?	image	http://localhost:9000/static/1780231908696-image.jpg	t	2026-05-31 14:51:51.997+02	2026-06-01 01:58:27.784+02	\N	\N	\N	\N	\N
01KSZAMWEVA8JMGZ9CM2AR5653	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Pouvez-vous m'accorder une remise ?	text	\N	t	2026-05-31 17:32:40.028+02	2026-06-01 01:58:27.795+02	\N	\N	\N	\N	\N
01KT01EMM5PTHRHBH78C8SS1Y6	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour, est-ce disponible ?	text	\N	t	2026-06-01 00:11:12.645+02	2026-06-01 01:58:27.831+02	\N	\N	\N	\N	\N
01KT01H60PVSV2MM7KZYKHMMN2	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Quel est le meilleur prix ?	text	\N	t	2026-06-01 00:12:35.991+02	2026-06-01 01:58:27.832+02	\N	\N	\N	\N	\N
01KT038K57NS4Y2GMHZDN9JDC7	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour, est-ce disponible ?	text	\N	t	2026-06-01 00:42:51.687+02	2026-06-01 01:58:27.834+02	\N	\N	\N	\N	\N
01KT059HVQ8C0V47VVPVADMWG9	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour, est-ce disponible ?	text	\N	t	2026-06-01 01:18:20.28+02	2026-06-01 01:58:27.835+02	\N	\N	\N	\N	\N
01KT067TAGP24139Z1N5P2CE44	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour, est-ce disponible ?	text	\N	t	2026-06-01 01:34:51.985+02	2026-06-01 01:58:27.844+02	\N	\N	\N	\N	\N
01KT0698XTKEJET9EYZ4WEPVNE	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour, est-ce disponible ?	text	\N	t	2026-06-01 01:35:39.706+02	2026-06-01 01:58:27.846+02	\N	\N	\N	\N	\N
01KT06BA1WQ2GNH7MF1E1PZX5F	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour, est-ce disponible ?	text	\N	t	2026-06-01 01:36:46.396+02	2026-06-01 01:58:27.852+02	\N	\N	\N	\N	\N
01KT06DWA2Z3CDNFECNXBSB0VR	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour, est-ce disponible ?	text	\N	t	2026-06-01 01:38:10.627+02	2026-06-01 01:58:27.859+02	\N	\N	\N	\N	\N
01KT06CD69P96YERDYY70P9A76	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Hjjjjjkk	text	\N	t	2026-06-01 01:37:22.377+02	2026-06-01 01:58:27.86+02	\N	\N	\N	\N	\N
01KT06QAV38PWYHT2HWZK6KE0D	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Quel est le meilleur prix ?	text	\N	t	2026-06-01 01:43:20.419+02	2026-06-01 01:58:27.861+02	\N	\N	\N	\N	\N
01KT07KGC71GS43DMFJ1V42D5Q	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Hhh	text	\N	t	2026-06-01 01:58:43.591+02	2026-06-01 01:58:44.589+02	\N	\N	\N	\N	\N
01KT0B4GQGADF366EY5H14KFRT	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Kkk	text	\N	t	2026-06-01 03:00:26.736+02	2026-06-01 03:00:27.77+02	\N	\N	\N	\N	\N
01KT07KXPH64YN8MRXG6E160CZ	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour, est-ce disponible ?	text	\N	t	2026-06-01 01:58:57.234+02	2026-06-01 01:58:57.365+02	\N	\N	\N	\N	\N
01KT07P27KGCW2NZ2VREF6QPA4	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Hello	text	\N	t	2026-06-01 02:00:07.411+02	2026-06-01 02:00:08.364+02	\N	\N	\N	\N	\N
01KT0B56YNVVB3KDJXVQ6J0B45	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Nnn	text	\N	t	2026-06-01 03:00:49.493+02	2026-06-01 03:00:49.532+02	\N	\N	\N	\N	\N
01KT07Q1E2KGFXRQ1ZRBF9EDCQ	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Kjjjjjjjjjhhhjkkjhhhggggggggggghhh	text	\N	t	2026-06-01 02:00:39.363+02	2026-06-01 02:00:39.411+02	\N	\N	\N	\N	\N
01KT0B664DFFJGAQ0T13E2YFN7	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Nnjj	text	\N	t	2026-06-01 03:01:21.421+02	2026-06-01 03:07:10.437+02	\N	\N	\N	\N	\N
01KT0B6YH1PT5AJRENXAMHKD7X	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Mmmm	text	\N	t	2026-06-01 03:01:46.401+02	2026-06-01 03:07:10.438+02	\N	\N	\N	\N	\N
01KT08261GQHEGVT9BR1MKS1VM	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Mmm	text	\N	t	2026-06-01 02:06:44.529+02	2026-06-01 02:20:25.17+02	\N	\N	\N	\N	\N
01KT0849R1TZ5MMFGM4D1100RX	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Quel est le meilleur prix ?	text	\N	t	2026-06-01 02:07:53.858+02	2026-06-01 02:20:25.18+02	\N	\N	\N	\N	\N
01KT08EHA0CE186GS5X3ZQ7CZ0	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Quel est le meilleur prix ?	text	\N	t	2026-06-01 02:13:29.28+02	2026-06-01 02:20:25.191+02	\N	\N	\N	\N	\N
01KT08H9R678HMDHGNWGPYATFZ	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour, est-ce disponible ?	text	\N	t	2026-06-01 02:14:59.846+02	2026-06-01 02:20:25.197+02	\N	\N	\N	\N	\N
01KT08KKZ8YK61H6M7MAKGC62Y	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Pouvez-vous m'accorder une remise ?	text	\N	t	2026-06-01 02:16:15.849+02	2026-06-01 02:20:25.21+02	\N	\N	\N	\N	\N
01KT08M34QQXFRF1VCCHZ2HJYA	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Nnn	text	\N	t	2026-06-01 02:16:31.383+02	2026-06-01 02:20:25.218+02	\N	\N	\N	\N	\N
01KT08M34VK14H4XHQSP68GFN3	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Nnn	text	\N	t	2026-06-01 02:16:31.387+02	2026-06-01 02:20:25.22+02	\N	\N	\N	\N	\N
01KT0B82S3XJJEA5R73XWDH3V6	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Kkk	text	\N	t	2026-06-01 03:02:23.523+02	2026-06-01 03:07:10.447+02	\N	\N	\N	\N	\N
01KT0B7B5C7STK76M3PKD5NBEQ	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Jkk	text	\N	t	2026-06-01 03:01:59.34+02	2026-06-01 03:07:10.452+02	\N	\N	\N	\N	\N
01KT0B8VXMT6MXWYKQQCKTYVRX	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Kik	text	\N	t	2026-06-01 03:02:49.268+02	2026-06-01 03:07:10.454+02	\N	\N	\N	\N	\N
01KT08VEE8PYW7A7VNPTC1HYE3	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Uu	text	\N	t	2026-06-01 02:20:32.328+02	2026-06-01 02:26:05.563+02	\N	\N	\N	\N	\N
01KT08XKAQAV16ZPPKWSX7AKWM	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Hhh	text	\N	t	2026-06-01 02:21:42.871+02	2026-06-01 02:26:05.569+02	\N	\N	\N	\N	\N
01KT08YB7YS2BD7NWN20Q3F5VT	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	No	text	\N	t	2026-06-01 02:22:07.358+02	2026-06-01 02:26:05.59+02	\N	\N	\N	\N	\N
01KT090YMC0XNMN542V68N66AE	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Jjjjj	text	\N	t	2026-06-01 02:23:32.748+02	2026-06-01 02:26:05.592+02	\N	\N	\N	\N	\N
01KT0959JFRWXNQSV6MGH6HA4T	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Bbbbn	text	\N	t	2026-06-01 02:25:55.023+02	2026-06-01 02:26:05.594+02	\N	\N	\N	\N	\N
01KT0D6HWMJS0VE8K9KQ154A57	01KSZCADYC4Z7KN64BXJ5023R1	customer	cus_01KSVPWBFY9T5MZXK47CYD788Q	Bonjour, est-ce disponible ?	text	\N	t	2026-06-01 03:36:30.612+02	2026-06-01 04:07:56.329+02	\N	\N	\N	\N	\N
01KSZCDGW0459W7CVZ2F35CZ4R	01KSZCADYC4Z7KN64BXJ5023R1	customer	cus_01KSVPWBFY9T5MZXK47CYD788Q	Bonjour, est-ce disponible ?	text	\N	t	2026-05-31 18:03:35.937+02	2026-06-01 04:07:56.332+02	\N	\N	\N	\N	\N
01KT095ZANNQBYE86C13TY575D	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour, est-ce disponible ?	text	\N	t	2026-06-01 02:26:17.301+02	2026-06-01 02:47:56.403+02	\N	\N	\N	\N	\N
01KT0AFYQENMC7JF9VR6SHW7C5	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Oooo	text	\N	t	2026-06-01 02:49:12.942+02	2026-06-01 02:53:58.436+02	\N	\N	\N	\N	\N
01KT0ACTMXYZTKE11X813MFSNF	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Aws	text	\N	t	2026-06-01 02:47:30.461+02	2026-06-01 02:53:58.439+02	\N	\N	\N	\N	\N
01KT0EYR06ZKRGGZ9TYZVH8B9N	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS		file	http://localhost:9000/static/1780279627320-video_1780279624693.mp4	t	2026-06-01 04:07:11.878+02	2026-06-01 12:50:26.014+02	\N	\N	\N	\N	\N
01KT1D3TFVR1BNJGVYNS8BHWW6	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Bonjour	text	\N	t	2026-06-01 12:54:15.547+02	2026-06-01 12:55:11.154+02	\N	\N	\N	\N	\N
01KT1D5455T90ZJ9G1NXDPE5WY	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Hello	text	\N	t	2026-06-01 12:54:58.213+02	2026-06-01 12:55:11.158+02	\N	\N	\N	\N	\N
01KT1D4MYC5X4VH2SMTTB4AGQR	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	No	text	\N	t	2026-06-01 12:54:42.637+02	2026-06-01 12:55:11.159+02	\N	\N	\N	\N	\N
01KXDJVHSKFKSQB2CRMJS3BRC3	01KVAQ8F8QB8M9CP6908W8S37S	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	bonjour!	text	\N	f	2026-07-13 13:12:34.611+02	2026-07-13 13:12:34.611+02	\N	\N	\N	\N	\N
01KXDKCFDTQT13SMHAA86M7P3A	01KSRC31WGAE8QWZC9PM6RMS3Y	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8		image	https://s3.eastmarket.africa/eastmarket/WhatsApp%20Image%202026-07-07%20at%2014.35.11-01KXDKCCXZ52WGWKEKM8MVD5H0.jpeg	f	2026-07-13 13:21:49.242+02	2026-07-13 13:21:49.242+02	\N	\N	\N	\N	\N
01KZYENPS148KRTTH7CFYWS9B6	01KVAQ8F8QB8M9CP6908W8S37S	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour\n\n📦 Sandale - 300 EUR	image	https://s3.eastmarket.africa/eastmarket/image-01KV5D13J6R2NW8G1966SMY1G3.jpg	f	2026-08-13 22:57:57.793+02	2026-08-13 22:57:57.793+02	\N	\N	\N	\N	\N
01KTEEM5N7BFFGAT2WPEN99RAY	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bo\n\n📦 Mapapa - 150 EUR	image	http://localhost:9000/static/1780302709862-image.jpg	f	2026-06-06 14:30:47.463+02	2026-08-13 23:29:50.384+02	2026-08-13 23:29:50.38+02	\N	\N	\N	\N
01KW3DGBTYNY9MMVJZK02A8J9J	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	bonjour	text	\N	f	2026-06-27 04:10:59.039+02	2026-08-13 23:30:27.942+02	2026-08-13 23:30:27.942+02	\N	\N	\N	\N
01KZYGJ7A3QHY9DAKG3BEP67Q8	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour	text	\N	f	2026-08-13 23:31:00.804+02	2026-08-13 23:31:00.804+02	\N	\N	\N	\N	\N
01KZYGKK5PSW30E7Y4JRT7R3NB	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	🎤 Message vocal	audio	https://s3.eastmarket.africa/eastmarket/voice_1786656699740-01KZYGKEGXPN22NY08MJY88BP3.m4a	f	2026-08-13 23:31:45.719+02	2026-08-13 23:31:45.719+02	\N	\N	\N	\N	\N
01KZYK0GJC8R5ST1XTF4WWHPCA	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	🎤 Message vocal	audio	https://s3.eastmarket.africa/eastmarket/voice_1786659222616-01KZYK0EDXPBAAA42VMV13F922.m4a	f	2026-08-14 00:13:46.189+02	2026-08-14 00:13:46.189+02	\N	\N	\N	\N	\N
01KZYK6NB93TDPEN156NJ2HDQR	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Hello	text	\N	f	2026-08-14 00:17:07.69+02	2026-08-14 00:17:07.69+02	\N	\N	\N	\N	\N
01M015G9Q7N1EHK1PZTWCYHMVK	01KVAQ8F8QB8M9CP6908W8S37S	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	💰 Offre : 30 USD pour Sandales plates pour femmes  (Modèles assortis)	offer	\N	f	2026-08-15 00:15:26.695+02	2026-08-15 00:15:26.695+02	\N	\N	\N	\N	{"title": "Sandales plates pour femmes  (Modèles assortis)", "amount": 30, "status": "pending", "currency": "USD", "thumbnail": "https://s3.eastmarket.africa/eastmarket/image-01KVAGYGR5HSSKB5HN5VY7MM8M.jpg", "product_id": "prod_01KVAHVT1115P37Z781SCQWX1W", "original_price": "200 USD"}
01M02AMP2EQFKEXFSNQ43SY38T	01KVAQ8F8QB8M9CP6908W8S37S	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	🎤 Message vocal	audio	https://s3.eastmarket.africa/eastmarket/voice_1786784665965-01M02AMMCD9EYS4SHVXB06S7JW.webm	f	2026-08-15 11:04:27.727+02	2026-08-15 11:04:27.727+02	\N	\N	\N	\N	\N
01M02AP051JRNHBE60YN1941YR	01KVAQ8F8QB8M9CP6908W8S37S	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	🎤 Message vocal	audio	https://s3.eastmarket.africa/eastmarket/voice_1786784708005-01M02ANXDZ9W45SPEDJ31QCEJ8.webm	f	2026-08-15 11:05:10.818+02	2026-08-15 11:05:10.818+02	\N	\N	\N	\N	\N
01M02B05R2Z9TETRWFKBZ9VCK5	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	🎤 Message vocal	audio	https://s3.eastmarket.africa/eastmarket/voice_1786785041230-01M02B02VBHRCP6ZTPC3BXBWPJ.webm	f	2026-08-15 11:10:44.226+02	2026-08-15 11:10:44.227+02	\N	\N	\N	\N	\N
01M02B169BYYDKX0ZSHE1S95TY	01KSRC31WGAE8QWZC9PM6RMS3Y	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	🎤 Message vocal	audio	https://s3.eastmarket.africa/eastmarket/voice_1786785075568-01M02B14CEW70WNRAA58MDTNGK.webm	f	2026-08-15 11:11:17.547+02	2026-08-15 11:11:17.547+02	\N	\N	\N	\N	\N
01KXDK36ZBFTPR7A50CFXBD8TB	01KSRC31WGAE8QWZC9PM6RMS3Y	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Je peux le faire, mais j'ai besoin de l'image elle-même.\n\nLe lien que tu as fourni (`https://www.eastmarket.africa/banner_pro.png`) n'est pas accessible directement de mon côté, donc je ne peux pas l'éditer.\n\n**Envoie-moi soit :**\n\n* l'image `banner_pro.png` en pièce jointe (glisser-déposer ou sélectionner le fichier),\n* ou une capture d'écran de la bannière.\n\nUne fois l'image reçue, je supprimerai proprement :\n\n1. tous les souliers,\n2. tous les prix,\n3. tous les badges (ex. réduction, promotion, etc.),\n\ntout en conservant le fond, le logo et le reste du design de manière naturelle.	text	\N	f	2026-07-13 13:16:45.675+02	2026-08-15 11:12:02.394+02	2026-08-15 11:12:02.393+02	\N	\N	\N	\N
01M02B730EDE603ZRF33V5PQG4	01KVAQ8F8QB8M9CP6908W8S37S	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Réactions et menu d'actions\n\nNouveau composant partagé components/chat/MessageActions.tsx :\n- MessageActionsMenu : petit bouton "•••" qui apparaît au survol d'un message (côté opposé à la bulle), ouvrant un menu avec 5 emojis de réaction rapide, "Copier le texte", et "Supprimer" (uniquement sur vos propres messages). S'ouvre vers le haut pour ne pas être coupé en bas de la conversation, se ferme au clic extérieur.\n- ReactionPills : pastilles affichées sous chaque message montrant les réactions déjà posées, avec compteur si plusieurs personnes ont réagi au même emoji.\n\nCâblage complet dans les deux surfaces (app/dashboard/chat/page.tsx et components/ChatWidgetModal.tsx) :\n- Réagir envoie via le socket si connecté (sinon fallback REST) — le backend fait déjà le toggle (ré-envoyer le même emoji le retire).\n- Écoute des événements reaction_added et message_deleted pour refléter en temps réel les réactions/suppressions faites depuis l'app mobile ou un autre onglet.\n- Copier utilise le presse-papiers du navigateur.\n- Supprimer demande confirmation, retire le message localement puis appelle la route DELETE.\n\nAucune régression de type (tsc --noEmit identique au baseline). Le widget flottant a maintenant la parité complète avec la page de chat pour ces fonctionnalités.	text	\N	f	2026-08-15 11:14:30.799+02	2026-08-15 11:14:30.799+02	\N	\N	\N	\N	\N
01M02B66YFS7GATA1RWKMP0AJP	01KVAQ8F8QB8M9CP6908W8S37S	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	bonjour!	text	\N	f	2026-08-15 11:14:02.064+02	2026-08-15 11:15:57.02+02	2026-08-15 11:15:57.019+02	\N	\N	\N	\N
01M02CE5C1SWTM4YAE9PC3H28Z	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	bonjour	text	\N	f	2026-08-15 11:35:51.169+02	2026-08-15 11:35:51.169+02	\N	\N	\N	01KZYK6NB93TDPEN156NJ2HDQR	\N
01M02CGQVNF1EQQZM4SMZNB14M	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	voici la video	file	https://s3.eastmarket.africa/eastmarket/grok-video-7c0352fc-8297-490c-b1d4-435555b89796-01M02CGKC8Y9FJHA3RMTX7M87C.mp4	f	2026-08-15 11:37:15.637+02	2026-08-15 11:37:15.637+02	\N	\N	\N	\N	\N
01M02CM1C0H9M2RWNDN3QJZ7KN	01KVAQ8F8QB8M9CP6908W8S37S	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	jj	text	\N	f	2026-08-15 11:39:03.681+02	2026-08-15 11:39:03.681+02	\N	\N	\N	\N	\N
01M02CMSCRR39TR54Y9V4JSGXK	01KVAQ8F8QB8M9CP6908W8S37S	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	hello	text	\N	f	2026-08-15 11:39:28.28+02	2026-08-15 11:39:28.28+02	\N	\N	\N	\N	\N
\.


--
-- Data for Name: mikro_orm_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mikro_orm_migrations (id, name, executed_at) FROM stdin;
1	Migration20240307161216	2026-05-24 12:23:03.408879+02
2	Migration20241210073813	2026-05-24 12:23:03.408879+02
3	Migration20250106142624	2026-05-24 12:23:03.408879+02
4	Migration20250120110820	2026-05-24 12:23:03.408879+02
5	Migration20240307132720	2026-05-24 12:23:03.461018+02
6	Migration20240719123015	2026-05-24 12:23:03.461018+02
7	Migration20241213063611	2026-05-24 12:23:03.461018+02
8	Migration20251010131115	2026-05-24 12:23:03.461018+02
9	InitialSetup20240401153642	2026-05-24 12:23:03.505061+02
10	Migration20240601111544	2026-05-24 12:23:03.505061+02
11	Migration202408271511	2026-05-24 12:23:03.505061+02
12	Migration20241122120331	2026-05-24 12:23:03.505061+02
13	Migration20241125090957	2026-05-24 12:23:03.505061+02
14	Migration20250411073236	2026-05-24 12:23:03.505061+02
15	Migration20250516081326	2026-05-24 12:23:03.505061+02
16	Migration20250910154539	2026-05-24 12:23:03.505061+02
17	Migration20250911092221	2026-05-24 12:23:03.505061+02
18	Migration20250929204438	2026-05-24 12:23:03.505061+02
19	Migration20251008132218	2026-05-24 12:23:03.505061+02
20	Migration20251011090511	2026-05-24 12:23:03.505061+02
21	Migration20230929122253	2026-05-24 12:23:03.595445+02
22	Migration20240322094407	2026-05-24 12:23:03.595445+02
23	Migration20240322113359	2026-05-24 12:23:03.595445+02
24	Migration20240322120125	2026-05-24 12:23:03.595445+02
25	Migration20240626133555	2026-05-24 12:23:03.595445+02
26	Migration20240704094505	2026-05-24 12:23:03.595445+02
27	Migration20241127114534	2026-05-24 12:23:03.595445+02
28	Migration20241127223829	2026-05-24 12:23:03.595445+02
29	Migration20241128055359	2026-05-24 12:23:03.595445+02
30	Migration20241212190401	2026-05-24 12:23:03.595445+02
31	Migration20250408145122	2026-05-24 12:23:03.595445+02
32	Migration20250409122219	2026-05-24 12:23:03.595445+02
33	Migration20251009110625	2026-05-24 12:23:03.595445+02
34	Migration20251112192723	2026-05-24 12:23:03.595445+02
35	Migration20240227120221	2026-05-24 12:23:03.695687+02
36	Migration20240617102917	2026-05-24 12:23:03.695687+02
37	Migration20240624153824	2026-05-24 12:23:03.695687+02
38	Migration20241211061114	2026-05-24 12:23:03.695687+02
39	Migration20250113094144	2026-05-24 12:23:03.695687+02
40	Migration20250120110700	2026-05-24 12:23:03.695687+02
41	Migration20250226130616	2026-05-24 12:23:03.695687+02
42	Migration20250508081510	2026-05-24 12:23:03.695687+02
43	Migration20250828075407	2026-05-24 12:23:03.695687+02
44	Migration20250909083125	2026-05-24 12:23:03.695687+02
45	Migration20250916120552	2026-05-24 12:23:03.695687+02
46	Migration20250917143818	2026-05-24 12:23:03.695687+02
47	Migration20250919122137	2026-05-24 12:23:03.695687+02
48	Migration20251006000000	2026-05-24 12:23:03.695687+02
49	Migration20251015113934	2026-05-24 12:23:03.695687+02
50	Migration20251107050148	2026-05-24 12:23:03.695687+02
51	Migration20240124154000	2026-05-24 12:23:03.790329+02
52	Migration20240524123112	2026-05-24 12:23:03.790329+02
53	Migration20240602110946	2026-05-24 12:23:03.790329+02
54	Migration20241211074630	2026-05-24 12:23:03.790329+02
55	Migration20251010130829	2026-05-24 12:23:03.790329+02
56	Migration20240115152146	2026-05-24 12:23:03.833915+02
57	Migration20240222170223	2026-05-24 12:23:03.860333+02
58	Migration20240831125857	2026-05-24 12:23:03.860333+02
59	Migration20241106085918	2026-05-24 12:23:03.860333+02
60	Migration20241205095237	2026-05-24 12:23:03.860333+02
61	Migration20241216183049	2026-05-24 12:23:03.860333+02
62	Migration20241218091938	2026-05-24 12:23:03.860333+02
63	Migration20250120115059	2026-05-24 12:23:03.860333+02
64	Migration20250212131240	2026-05-24 12:23:03.860333+02
65	Migration20250326151602	2026-05-24 12:23:03.860333+02
66	Migration20250508081553	2026-05-24 12:23:03.860333+02
67	Migration20251017153909	2026-05-24 12:23:03.860333+02
68	Migration20251208130704	2026-05-24 12:23:03.860333+02
69	Migration20240205173216	2026-05-24 12:23:03.936823+02
70	Migration20240624200006	2026-05-24 12:23:03.936823+02
71	Migration20250120110744	2026-05-24 12:23:03.936823+02
72	InitialSetup20240221144943	2026-05-24 12:23:03.975694+02
73	Migration20240604080145	2026-05-24 12:23:03.975694+02
74	Migration20241205122700	2026-05-24 12:23:03.975694+02
75	Migration20251015123842	2026-05-24 12:23:03.975694+02
76	InitialSetup20240227075933	2026-05-24 12:23:04.006521+02
77	Migration20240621145944	2026-05-24 12:23:04.006521+02
78	Migration20241206083313	2026-05-24 12:23:04.006521+02
79	Migration20251202184737	2026-05-24 12:23:04.006521+02
80	Migration20251212161429	2026-05-24 12:23:04.006521+02
81	Migration20240227090331	2026-05-24 12:23:04.046603+02
82	Migration20240710135844	2026-05-24 12:23:04.046603+02
83	Migration20240924114005	2026-05-24 12:23:04.046603+02
84	Migration20241212052837	2026-05-24 12:23:04.046603+02
85	InitialSetup20240228133303	2026-05-24 12:23:04.093465+02
86	Migration20240624082354	2026-05-24 12:23:04.093465+02
87	Migration20240225134525	2026-05-24 12:23:04.119432+02
88	Migration20240806072619	2026-05-24 12:23:04.119432+02
89	Migration20241211151053	2026-05-24 12:23:04.119432+02
90	Migration20250115160517	2026-05-24 12:23:04.119432+02
91	Migration20250120110552	2026-05-24 12:23:04.119432+02
92	Migration20250123122334	2026-05-24 12:23:04.119432+02
93	Migration20250206105639	2026-05-24 12:23:04.119432+02
94	Migration20250207132723	2026-05-24 12:23:04.119432+02
95	Migration20250625084134	2026-05-24 12:23:04.119432+02
96	Migration20250924135437	2026-05-24 12:23:04.119432+02
97	Migration20250929124701	2026-05-24 12:23:04.119432+02
98	Migration20240219102530	2026-05-24 12:23:04.184541+02
99	Migration20240604100512	2026-05-24 12:23:04.184541+02
100	Migration20240715102100	2026-05-24 12:23:04.184541+02
101	Migration20240715174100	2026-05-24 12:23:04.184541+02
102	Migration20240716081800	2026-05-24 12:23:04.184541+02
103	Migration20240801085921	2026-05-24 12:23:04.184541+02
104	Migration20240821164505	2026-05-24 12:23:04.184541+02
105	Migration20240821170920	2026-05-24 12:23:04.184541+02
106	Migration20240827133639	2026-05-24 12:23:04.184541+02
107	Migration20240902195921	2026-05-24 12:23:04.184541+02
108	Migration20240913092514	2026-05-24 12:23:04.184541+02
109	Migration20240930122627	2026-05-24 12:23:04.184541+02
110	Migration20241014142943	2026-05-24 12:23:04.184541+02
111	Migration20241106085223	2026-05-24 12:23:04.184541+02
112	Migration20241129124827	2026-05-24 12:23:04.184541+02
113	Migration20241217162224	2026-05-24 12:23:04.184541+02
114	Migration20250326151554	2026-05-24 12:23:04.184541+02
115	Migration20250522181137	2026-05-24 12:23:04.184541+02
116	Migration20250702095353	2026-05-24 12:23:04.184541+02
117	Migration20250704120229	2026-05-24 12:23:04.184541+02
118	Migration20250910130000	2026-05-24 12:23:04.184541+02
119	Migration20251016160403	2026-05-24 12:23:04.184541+02
120	Migration20251016182939	2026-05-24 12:23:04.184541+02
121	Migration20251017155709	2026-05-24 12:23:04.184541+02
122	Migration20251114100559	2026-05-24 12:23:04.184541+02
123	Migration20251125164002	2026-05-24 12:23:04.184541+02
124	Migration20251210112909	2026-05-24 12:23:04.184541+02
125	Migration20251210112924	2026-05-24 12:23:04.184541+02
126	Migration20251225120947	2026-05-24 12:23:04.184541+02
127	Migration20250717162007	2026-05-24 12:23:04.327823+02
128	Migration20240205025928	2026-05-24 12:23:04.358396+02
129	Migration20240529080336	2026-05-24 12:23:04.358396+02
130	Migration20241202100304	2026-05-24 12:23:04.358396+02
131	Migration20240214033943	2026-05-24 12:23:04.42679+02
132	Migration20240703095850	2026-05-24 12:23:04.42679+02
133	Migration20241202103352	2026-05-24 12:23:04.42679+02
134	Migration20240311145700_InitialSetupMigration	2026-05-24 12:23:04.464531+02
135	Migration20240821170957	2026-05-24 12:23:04.464531+02
136	Migration20240917161003	2026-05-24 12:23:04.464531+02
137	Migration20241217110416	2026-05-24 12:23:04.464531+02
138	Migration20250113122235	2026-05-24 12:23:04.464531+02
139	Migration20250120115002	2026-05-24 12:23:04.464531+02
140	Migration20250822130931	2026-05-24 12:23:04.464531+02
141	Migration20250825132614	2026-05-24 12:23:04.464531+02
142	Migration20251114133146	2026-05-24 12:23:04.464531+02
143	Migration20240509083918_InitialSetupMigration	2026-05-24 12:23:04.571233+02
144	Migration20240628075401	2026-05-24 12:23:04.571233+02
145	Migration20240830094712	2026-05-24 12:23:04.571233+02
146	Migration20250120110514	2026-05-24 12:23:04.571233+02
147	Migration20251028172715	2026-05-24 12:23:04.571233+02
148	Migration20251121123942	2026-05-24 12:23:04.571233+02
149	Migration20251121150408	2026-05-24 12:23:04.571233+02
150	Migration20231228143900	2026-05-24 12:23:04.679739+02
151	Migration20241206101446	2026-05-24 12:23:04.679739+02
152	Migration20250128174331	2026-05-24 12:23:04.679739+02
153	Migration20250505092459	2026-05-24 12:23:04.679739+02
154	Migration20250819104213	2026-05-24 12:23:04.679739+02
155	Migration20250819110924	2026-05-24 12:23:04.679739+02
156	Migration20250908080305	2026-05-24 12:23:04.679739+02
157	Migration20240708151444	2026-05-24 12:23:04.798487+02
158	Migration20250311091542	2026-05-24 12:23:04.798487+02
159	Migration20260417000000	2026-05-24 12:23:04.798487+02
160	Migration20260419000000	2026-05-24 12:23:04.798487+02
161	Migration20260418000000	2026-05-24 12:23:04.838319+02
162	Migration20260418100000	2026-05-24 12:23:04.86748+02
163	Migration20260418300000	2026-05-24 12:23:04.893318+02
164	Migration20260418200000	2026-05-24 12:23:04.917686+02
165	Migration20260418210000_AddStreamingFields	2026-05-24 12:23:04.917686+02
166	Migration20260511023721	2026-05-24 12:23:04.991917+02
167	Migration20260526032822	2026-05-26 05:28:25.262656+02
168	Migration20260526080218	2026-05-26 10:02:23.121222+02
169	Migration20260526100000	2026-05-26 12:36:41.328672+02
170	Migration20260530095813	2026-05-30 11:58:43.852562+02
171	Migration20260601155801	2026-06-01 17:59:32.333994+02
172	Migration20251208124155	2026-06-06 16:39:03.217928+02
173	Migration20251215083927	2026-06-06 16:39:03.217928+02
174	Migration20251218140235	2026-06-06 16:39:03.217928+02
175	Migration20260108122757	2026-06-06 16:39:03.217928+02
176	Migration20260615220014	2026-06-16 00:05:13.531526+02
177	Migration20260811233626	2026-08-12 01:36:42.019292+02
178	Migration20260811234606	2026-08-12 01:46:37.974626+02
179	Migration20260812001532	2026-08-12 02:15:45.064197+02
180	Migration20260812013631	2026-08-12 03:36:52.121968+02
181	Migration20260812013939	2026-08-12 03:40:02.896353+02
182	Migration20260812014502	2026-08-12 03:45:24.066051+02
183	Migration20260812130802	2026-08-12 15:08:29.586565+02
184	Migration20260812131826	2026-08-12 15:19:00.817992+02
185	Migration20260812153041	2026-08-12 17:31:10.359981+02
186	Migration20260813000000	2026-08-13 22:49:55.589872+02
187	Migration20260813010000	2026-08-13 23:09:18.031835+02
188	Migration20260813020000	2026-08-13 23:10:21.042805+02
189	Migration20260813030000	2026-08-13 23:15:23.718116+02
190	Migration20260813040000	2026-08-13 23:30:49.711135+02
191	Migration20260813050000	2026-08-13 23:32:24.498784+02
192	Migration20260813060000	2026-08-13 23:39:00.548633+02
193	Migration20260813070000	2026-08-13 23:42:33.26505+02
\.


--
-- Data for Name: notification; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notification (id, "to", channel, template, data, trigger_type, resource_id, resource_type, receiver_id, original_notification_id, idempotency_key, external_id, provider_id, created_at, updated_at, deleted_at, status, "from", provider_data) FROM stdin;
\.


--
-- Data for Name: notification_preference; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notification_preference (id, recipient_id, recipient_type, prefs, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: notification_provider; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notification_provider (id, handle, name, is_enabled, channels, created_at, updated_at, deleted_at) FROM stdin;
local	local	local	t	{feed}	2026-05-24 12:23:06.72+02	2026-05-24 12:23:06.72+02	\N
\.


--
-- Data for Name: order; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."order" (id, region_id, display_id, customer_id, version, sales_channel_id, status, is_draft_order, email, currency_code, shipping_address_id, billing_address_id, no_notification, metadata, created_at, updated_at, deleted_at, canceled_at, custom_display_id, locale) FROM stdin;
order_01KZSRPGT61RWGZEV4XWSST4DB	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	17	cus_01KZSRPF04TZB7SAT86MV8YP2J	1	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pending	f	socialprooftest2@example.com	usd	ordaddr_01KZSRPGSY24JCPH5P1N71Z757	\N	f	\N	2026-08-12 03:16:58.06+02	2026-08-12 03:16:58.06+02	\N	\N	\N	\N
order_01KSYNR3FQYDZ176SCBXMTC2CA	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	2	cus_01KSR173ECD4A2AJF6H3R1H2J8	2	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pending	f	princelulinda32@gmail.com	usd	ordaddr_01KSYNR3FN03GDG9077C2C6GXP	\N	f	\N	2026-05-31 11:27:25.432+02	2026-05-31 11:27:52.798+02	\N	\N	\N	\N
order_01KZSRT94K7A6N76KXHBVTJKMJ	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	18	cus_01KZSRT7Q29W9N12GXQK6SVY8E	1	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pending	f	debugtest@example.com	usd	ordaddr_01KZSRT94C23F3KZGVXWB4DCS5	\N	f	\N	2026-08-12 03:19:01.273+02	2026-08-12 03:19:01.273+02	\N	\N	\N	\N
order_01KZSS4E0E2TDSQ1CZW34GVH80	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	19	cus_01KZSS4CJSGT6HDXZ310W1C82K	1	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pending	f	debugtest3@example.com	usd	ordaddr_01KZSS4E07NQ478KKJ84D0GYV0	\N	f	\N	2026-08-12 03:24:33.941+02	2026-08-12 03:24:33.941+02	\N	\N	\N	\N
order_01KZSS713JEJG13A30NW7X2RR7	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	20	cus_01KZSS6ZQW5RQBDPWQCEDQ0BVR	1	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pending	f	debugtest4@example.com	usd	ordaddr_01KZSS713AP83MWWSH6E151W5C	\N	f	\N	2026-08-12 03:25:59.032+02	2026-08-12 03:25:59.032+02	\N	\N	\N	\N
order_01KSYPW2RSZ248CCQ1F6HZEQJ5	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	3	cus_01KSR173ECD4A2AJF6H3R1H2J8	4	sc_01KSCR9E3HDNX82KGM4FXZDGP1	completed	f	princelulinda32@gmail.com	usd	ordaddr_01KSYPW2RRF7E5T4J9ZWDDGZMK	\N	f	\N	2026-05-31 11:47:04.346+02	2026-05-31 12:04:49.1+02	\N	\N	\N	\N
order_01KSYZ528J6XCKJY7DR20SPNTZ	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	4	cus_01KSR173ECD4A2AJF6H3R1H2J8	1	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pending	f	princelulinda32@gmail.com	usd	ordaddr_01KSYZ528GR7ZSD3GYJBZK4DEP	\N	f	\N	2026-05-31 14:11:47.347+02	2026-05-31 14:11:47.347+02	\N	\N	\N	\N
order_01KSYZ9NKNR0ZFP1NHRRJ6C4H0	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	5	cus_01KSR173ECD4A2AJF6H3R1H2J8	1	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pending	f	princelulinda32@gmail.com	usd	ordaddr_01KSYZ9NKJKQY8SZ2KEJNN9RCF	\N	f	\N	2026-05-31 14:14:18.231+02	2026-05-31 14:14:18.231+02	\N	\N	\N	\N
order_01KSYZEHBJT6J0R02PCEWAQXYW	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	6	cus_01KSR173ECD4A2AJF6H3R1H2J8	1	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pending	f	princelulinda32@gmail.com	usd	ordaddr_01KSYZEHBF966Q5JSBGGV5XJF4	\N	f	\N	2026-05-31 14:16:57.716+02	2026-05-31 14:16:57.716+02	\N	\N	\N	\N
order_01KSZ025ATTT8ABSP8NXJK5XXH	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	7	cus_01KSR173ECD4A2AJF6H3R1H2J8	1	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pending	f	princelulinda32@gmail.com	usd	ordaddr_01KSZ025AQANEFSPPBX92GTKZH	\N	f	\N	2026-05-31 14:27:40.764+02	2026-05-31 14:27:40.764+02	\N	\N	\N	\N
order_01KSZ040QG8CAWV63TQC132B9P	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	8	cus_01KSR173ECD4A2AJF6H3R1H2J8	1	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pending	f	princelulinda32@gmail.com	usd	ordaddr_01KSZ040QCCTEJA9TQ42SPCTFD	\N	f	\N	2026-05-31 14:28:41.586+02	2026-05-31 14:28:41.586+02	\N	\N	\N	\N
order_01KSZ0VB193K4QY97BW6PNNHWE	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	9	cus_01KSR173ECD4A2AJF6H3R1H2J8	1	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pending	f	princelulinda32@gmail.com	usd	ordaddr_01KSZ0VB18BE38HMDS9C4AAQ4T	\N	f	\N	2026-05-31 14:41:25.803+02	2026-05-31 14:41:25.803+02	\N	\N	\N	\N
order_01KSWZ94QHBKV096ESCTPKNS2N	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	1	cus_01KSR173ECD4A2AJF6H3R1H2J8	3	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pending	f	princelulinda10@gmail.com	usd	ordaddr_01KSWZ94QBFWCV23FQSBGT6K3B	\N	f	\N	2026-05-30 19:35:32.087+02	2026-06-01 09:40:48.922+02	\N	\N	\N	\N
order_01KZSRKT0QNS81MFMA4G05RZ8E	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	16	cus_01KZSRK3GY7H9W4XQEVRX7V4ZX	1	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pending	f	socialprooftest@example.com	usd	ordaddr_01KZSRKT0G7CDEHMGD946KSFCX	\N	f	\N	2026-08-12 03:15:29.181+02	2026-08-12 03:15:29.181+02	\N	\N	\N	\N
order_01KZTFBQSNE8M83ECV3F4F3K9J	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	21	cus_01KZTFASX63451FWPYQZST4A8M	1	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pending	f	referredbuyer@example.com	usd	ordaddr_01KZTFBQSDX6FZV7FKPSQ56FWZ	\N	f	\N	2026-08-12 09:53:02.011+02	2026-08-12 09:53:02.011+02	\N	\N	\N	\N
\.


--
-- Data for Name: order_address; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_address (id, customer_id, company, first_name, last_name, address_1, address_2, city, country_code, province, postal_code, phone, metadata, created_at, updated_at, deleted_at) FROM stdin;
ordaddr_01KSWZ94QBFWCV23FQSBGT6K3B	\N	\N	prince	-	Line 1		Musenyi	bi	\N			\N	2026-05-30 19:35:22.079+02	2026-05-30 19:35:22.079+02	\N
ordaddr_01KSYNR3FN03GDG9077C2C6GXP	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-31 11:27:03.667+02	2026-05-31 11:27:03.667+02	\N
ordaddr_01KSYPW2RRF7E5T4J9ZWDDGZMK	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-31 11:46:43.692+02	2026-05-31 11:46:43.692+02	\N
ordaddr_01KSYZ528GR7ZSD3GYJBZK4DEP	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-31 14:11:36.462+02	2026-05-31 14:11:36.462+02	\N
ordaddr_01KSYZ9NKJKQY8SZ2KEJNN9RCF	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-31 14:14:08.553+02	2026-05-31 14:14:08.553+02	\N
ordaddr_01KSYZEHBF966Q5JSBGGV5XJF4	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-31 14:16:37.238+02	2026-05-31 14:16:37.238+02	\N
ordaddr_01KSZ025AQANEFSPPBX92GTKZH	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-31 14:27:33.309+02	2026-05-31 14:27:33.309+02	\N
ordaddr_01KSZ040QCCTEJA9TQ42SPCTFD	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-31 14:28:34.564+02	2026-05-31 14:28:34.564+02	\N
ordaddr_01KSZ0VB18BE38HMDS9C4AAQ4T	\N	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-31 14:41:17.118+02	2026-05-31 14:41:17.118+02	\N
ordaddr_01KZSRKT0G7CDEHMGD946KSFCX	\N	\N	Social	Proof	1 Test St	\N	Testville	cg	\N	00000	+33600000000	\N	2026-08-12 03:15:06.171+02	2026-08-12 03:15:06.171+02	\N
ordaddr_01KZSRPGSY24JCPH5P1N71Z757	\N	\N	Social	Proof2	1 Test St	\N	Testville	cg	\N	00000	+33600000000	\N	2026-08-12 03:16:56.23+02	2026-08-12 03:16:56.23+02	\N
ordaddr_01KZSRT94C23F3KZGVXWB4DCS5	\N	\N	Debug	Test	1 Test St	\N	Testville	cg	\N	00000	+33600000000	\N	2026-08-12 03:18:59.836+02	2026-08-12 03:18:59.836+02	\N
ordaddr_01KZSS4E07NQ478KKJ84D0GYV0	\N	\N	Debug	Three	1 Test St	\N	Testville	cg	\N	00000	+33600000000	\N	2026-08-12 03:24:32.499+02	2026-08-12 03:24:32.499+02	\N
ordaddr_01KZSS713AP83MWWSH6E151W5C	\N	\N	Debug	Four	1 Test St	\N	Testville	cg	\N	00000	+33600000000	\N	2026-08-12 03:25:57.653+02	2026-08-12 03:25:57.653+02	\N
ordaddr_01KZTFBQSDX6FZV7FKPSQ56FWZ	\N	\N	Referred	Buyer	1 Test St	\N	Testville	cg	\N	00000	+33600000000	\N	2026-08-12 09:53:00.605+02	2026-08-12 09:53:00.605+02	\N
\.


--
-- Data for Name: order_cart; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_cart (order_id, cart_id, id, created_at, updated_at, deleted_at) FROM stdin;
order_01KSWZ94QHBKV096ESCTPKNS2N	cart_01KSR17JJKRN19AW6DGG1ZNZXC	ordercart_01KSWZ94V0C47G0ZANVVGF2XMY	2026-05-30 19:35:32.192063+02	2026-05-30 19:35:32.192063+02	\N
order_01KSYNR3FQYDZ176SCBXMTC2CA	cart_01KSYNPXZ7GKJRHYWE8HXZQPEJ	ordercart_01KSYNR3GHE3Z42KXEC9KAA168	2026-05-31 11:27:25.456868+02	2026-05-31 11:27:25.456868+02	\N
order_01KSYPW2RSZ248CCQ1F6HZEQJ5	cart_01KSYPV5SG04S1KMPP10R93K65	ordercart_01KSYPW2T0YV4MZHGJG8VQSAFF	2026-05-31 11:47:04.384192+02	2026-05-31 11:47:04.384192+02	\N
order_01KSYZ528J6XCKJY7DR20SPNTZ	cart_01KSYRTG3P2TYAY5NJK34GCSQC	ordercart_01KSYZ529Q3BFJXNKP6QV4GVVW	2026-05-31 14:11:47.383183+02	2026-05-31 14:11:47.383183+02	\N
order_01KSYZ9NKNR0ZFP1NHRRJ6C4H0	cart_01KSYZ93PAWAQ3YMSX95CPEDAW	ordercart_01KSYZ9NMM9A2320KYQPW7YMEJ	2026-05-31 14:14:18.260354+02	2026-05-31 14:14:18.260354+02	\N
order_01KSYZEHBJT6J0R02PCEWAQXYW	cart_01KSYZD7RA6NWZ1QPAGBP73146	ordercart_01KSYZEHCK140ETNDHS1B0WQNP	2026-05-31 14:16:57.74757+02	2026-05-31 14:16:57.74757+02	\N
order_01KSZ025ATTT8ABSP8NXJK5XXH	cart_01KSZ01P234X82AKV9N28KZVJA	ordercart_01KSZ025CPQ0BF402XERS8845H	2026-05-31 14:27:40.821903+02	2026-05-31 14:27:40.821903+02	\N
order_01KSZ040QG8CAWV63TQC132B9P	cart_01KSZ03JDPKWSSPAQ2AB3D3A5B	ordercart_01KSZ040RRBKWGY4CYCRG1FGET	2026-05-31 14:28:41.624099+02	2026-05-31 14:28:41.624099+02	\N
order_01KSZ0VB193K4QY97BW6PNNHWE	cart_01KSZ0TTA6QMT1NTEB871F845G	ordercart_01KSZ0VB28PHFMT3YZV8WGMT6G	2026-05-31 14:41:25.832179+02	2026-05-31 14:41:25.832179+02	\N
order_01KT9CPZEAY25M28V9MKEET6A7	cart_01KT1VZFSW5FDQCERA8BX242EF	ordercart_01KT9CPZFXQGAGHNHA1P4YZYCZ	2026-06-04 15:21:10.140693+02	2026-06-04 15:21:10.212+02	2026-06-04 15:21:10.211+02
order_01KT9CQAG3DF5ZA2EV7DV4BQX0	cart_01KT1VZFSW5FDQCERA8BX242EF	ordercart_01KT9CQAH355WNBSNME4P7N889	2026-06-04 15:21:21.442739+02	2026-06-04 15:21:21.477+02	2026-06-04 15:21:21.477+02
order_01KT9CQP69M9BGSJPWFT94WPW2	cart_01KT1VZFSW5FDQCERA8BX242EF	ordercart_01KT9CQP7BZB8GEM1ZVPP13PRQ	2026-06-04 15:21:33.419356+02	2026-06-04 15:21:33.456+02	2026-06-04 15:21:33.456+02
order_01KT9CTS56P51FG4WXAG8CCTRD	cart_01KT1VZFSW5FDQCERA8BX242EF	ordercart_01KT9CTS5VCSKN6A89X4JPGQPH	2026-06-04 15:23:14.747346+02	2026-06-04 15:23:14.774+02	2026-06-04 15:23:14.774+02
order_01KT9CXBGJ7DBRZ8ZJG8TARDTC	cart_01KT1VZFSW5FDQCERA8BX242EF	ordercart_01KT9CXBHMQ8X71JXEYQN56607	2026-06-04 15:24:39.092413+02	2026-06-04 15:24:39.124+02	2026-06-04 15:24:39.124+02
order_01KTBF4WV33ZQZ0VVF4TZTS0GV	cart_01KT1VZFSW5FDQCERA8BX242EF	ordercart_01KTBF4WZ6H4DY8ZK1DD324JPD	2026-06-05 10:42:12.325042+02	2026-06-05 10:42:12.442+02	2026-06-05 10:42:12.441+02
order_01KZSRKT0QNS81MFMA4G05RZ8E	cart_01KZSNW83S6222HZ28KHMG9EXJ	ordercart_01KZSRKT3XJEY1H1JQ7W72D0AZ	2026-08-12 03:15:29.2766+02	2026-08-12 03:15:29.2766+02	\N
order_01KZSRPGT61RWGZEV4XWSST4DB	cart_01KZSRP068BQQP8TQNEB823ZCV	ordercart_01KZSRPGX76DF1FMS5H8CVPY4B	2026-08-12 03:16:58.148394+02	2026-08-12 03:16:58.148394+02	\N
order_01KZSRT94K7A6N76KXHBVTJKMJ	cart_01KZSRT71KMHMWX9DFAXP33T7W	ordercart_01KZSRT977HKZVV79W4ZE2ESJT	2026-08-12 03:19:01.348612+02	2026-08-12 03:19:01.348612+02	\N
order_01KZSS4E0E2TDSQ1CZW34GVH80	cart_01KZSS4BKPNCHBFWMGN0624ZPN	ordercart_01KZSS4E3F44E5P1CAEXB68CQH	2026-08-12 03:24:34.024726+02	2026-08-12 03:24:34.024726+02	\N
order_01KZSS713JEJG13A30NW7X2RR7	cart_01KZSS6Z30MMS0FNSH6K4H7HKY	ordercart_01KZSS716D183FB19F03PP7ZRC	2026-08-12 03:25:59.114576+02	2026-08-12 03:25:59.114576+02	\N
order_01KZTFBQSNE8M83ECV3F4F3K9J	cart_01KZTFBNRPB6DYYAKDVDE4TQPB	ordercart_01KZTFBQWFPWRXVGHYN36501AV	2026-08-12 09:53:02.09508+02	2026-08-12 09:53:02.09508+02	\N
\.


--
-- Data for Name: order_change; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_change (id, order_id, version, description, status, internal_note, created_by, requested_by, requested_at, confirmed_by, confirmed_at, declined_by, declined_reason, metadata, declined_at, canceled_by, canceled_at, created_at, updated_at, change_type, deleted_at, return_id, claim_id, exchange_id, carry_over_promotions) FROM stdin;
ordch_01KSYGK33RG5SNGT5S4FXGGQRJ	order_01KSWZ94QHBKV096ESCTPKNS2N	2	\N	confirmed	\N	\N	\N	\N	\N	2026-05-31 09:57:18.339+02	\N	\N	\N	\N	\N	\N	2026-05-31 09:57:18.328+02	2026-05-31 09:57:18.341+02	\N	\N	\N	\N	\N	\N
ordch_01KSYNRY6DXJSN65JZQZBPMVXE	order_01KSYNR3FQYDZ176SCBXMTC2CA	2	\N	confirmed	\N	\N	\N	\N	\N	2026-05-31 11:27:52.785+02	\N	\N	\N	\N	\N	\N	2026-05-31 11:27:52.781+02	2026-05-31 11:27:52.787+02	\N	\N	\N	\N	\N	\N
ordch_01KSYPWSG5184W14WPN8479X62	order_01KSYPW2RSZ248CCQ1F6HZEQJ5	2	\N	confirmed	\N	\N	\N	\N	\N	2026-05-31 11:47:27.626+02	\N	\N	\N	\N	\N	\N	2026-05-31 11:47:27.621+02	2026-05-31 11:47:27.627+02	\N	\N	\N	\N	\N	\N
ordch_01KSYQFJCB80SE8ABWRY2NQVKZ	order_01KSYPW2RSZ248CCQ1F6HZEQJ5	3	\N	confirmed	\N	\N	\N	\N	\N	2026-05-31 11:57:42.933+02	\N	\N	\N	\N	\N	\N	2026-05-31 11:57:42.924+02	2026-05-31 11:57:42.937+02	\N	\N	\N	\N	\N	\N
ordch_01KSYQWJH7D14ZCMQ8R68CQ4MX	order_01KSYPW2RSZ248CCQ1F6HZEQJ5	4	\N	confirmed	\N	\N	\N	\N	\N	2026-05-31 12:04:49.072+02	\N	\N	\N	\N	\N	\N	2026-05-31 12:04:49.063+02	2026-05-31 12:04:49.073+02	\N	\N	\N	\N	\N	\N
ordch_01KT121KVP3JRXF2925E9PM2YE	order_01KSWZ94QHBKV096ESCTPKNS2N	3	\N	confirmed	\N	\N	\N	\N	\N	2026-06-01 09:40:48.901+02	\N	\N	\N	\N	\N	\N	2026-06-01 09:40:48.887+02	2026-06-01 09:40:48.904+02	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: order_change_action; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_change_action (id, order_id, version, ordering, order_change_id, reference, reference_id, action, details, amount, raw_amount, internal_note, applied, created_at, updated_at, deleted_at, return_id, claim_id, exchange_id) FROM stdin;
ordchact_01KSYGK33RCTK7NC6EECKS52C7	order_01KSWZ94QHBKV096ESCTPKNS2N	2	1	ordch_01KSYGK33RG5SNGT5S4FXGGQRJ	fulfillment	ful_01KSYGK32E7WQ4D5YNPM4C9H8C	FULFILL_ITEM	{"quantity": 1, "reference_id": "ordli_01KSWZ94QMZSFYTT7W2RETNS1N"}	\N	\N	\N	t	2026-05-31 09:57:18.329+02	2026-05-31 09:57:18.361+02	\N	\N	\N	\N
ordchact_01KSYNRY6DGYZVNY3CT1B9B0JJ	order_01KSYNR3FQYDZ176SCBXMTC2CA	2	2	ordch_01KSYNRY6DXJSN65JZQZBPMVXE	fulfillment	ful_01KSYNRY5QE6WC9XE86D6X2MPW	FULFILL_ITEM	{"quantity": 1, "reference_id": "ordli_01KSYNR3FRS9WA22GY059T0G28"}	\N	\N	\N	t	2026-05-31 11:27:52.781+02	2026-05-31 11:27:52.798+02	\N	\N	\N	\N
ordchact_01KSYPWSG40GBZVDPF2KTRTJF7	order_01KSYPW2RSZ248CCQ1F6HZEQJ5	2	3	ordch_01KSYPWSG5184W14WPN8479X62	fulfillment	ful_01KSYPWSFHJ0HXZSVH3G0SZ4WP	FULFILL_ITEM	{"quantity": 3, "reference_id": "ordli_01KSYPW2RSYNTHG25MJ844X3J6"}	\N	\N	\N	t	2026-05-31 11:47:27.621+02	2026-05-31 11:47:27.644+02	\N	\N	\N	\N
ordchact_01KSYQFJCBHQKET8W74X61CAWP	order_01KSYPW2RSZ248CCQ1F6HZEQJ5	3	4	ordch_01KSYQFJCB80SE8ABWRY2NQVKZ	fulfillment	ful_01KSYPWSFHJ0HXZSVH3G0SZ4WP	SHIP_ITEM	{"quantity": "3", "reference_id": "ordli_01KSYPW2RSYNTHG25MJ844X3J6"}	\N	\N	\N	t	2026-05-31 11:57:42.924+02	2026-05-31 11:57:42.963+02	\N	\N	\N	\N
ordchact_01KSYQWJH7XYXT93R5R15B8CF1	order_01KSYPW2RSZ248CCQ1F6HZEQJ5	4	5	ordch_01KSYQWJH7D14ZCMQ8R68CQ4MX	fulfillment	ful_01KSYPWSFHJ0HXZSVH3G0SZ4WP	DELIVER_ITEM	{"quantity": "3", "reference_id": "ordli_01KSYPW2RSYNTHG25MJ844X3J6"}	\N	\N	\N	t	2026-05-31 12:04:49.064+02	2026-05-31 12:04:49.1+02	\N	\N	\N	\N
ordchact_01KT121KVP6HG9E69AQZNYPC5V	order_01KSWZ94QHBKV096ESCTPKNS2N	3	6	ordch_01KT121KVP3JRXF2925E9PM2YE	fulfillment	ful_01KSYGK32E7WQ4D5YNPM4C9H8C	SHIP_ITEM	{"quantity": "1", "reference_id": "ordli_01KSWZ94QMZSFYTT7W2RETNS1N"}	\N	\N	\N	t	2026-06-01 09:40:48.887+02	2026-06-01 09:40:48.922+02	\N	\N	\N	\N
\.


--
-- Data for Name: order_claim; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_claim (id, order_id, return_id, order_version, display_id, type, no_notification, refund_amount, raw_refund_amount, metadata, created_at, updated_at, deleted_at, canceled_at, created_by) FROM stdin;
\.


--
-- Data for Name: order_claim_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_claim_item (id, claim_id, item_id, is_additional_item, reason, quantity, raw_quantity, note, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_claim_item_image; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_claim_item_image (id, claim_item_id, url, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_credit_line; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_credit_line (id, order_id, reference, reference_id, amount, raw_amount, metadata, created_at, updated_at, deleted_at, version) FROM stdin;
\.


--
-- Data for Name: order_exchange; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_exchange (id, order_id, return_id, order_version, display_id, no_notification, allow_backorder, difference_due, raw_difference_due, metadata, created_at, updated_at, deleted_at, canceled_at, created_by) FROM stdin;
\.


--
-- Data for Name: order_exchange_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_exchange_item (id, exchange_id, item_id, quantity, raw_quantity, note, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_fulfillment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_fulfillment (order_id, fulfillment_id, id, created_at, updated_at, deleted_at) FROM stdin;
order_01KSWZ94QHBKV096ESCTPKNS2N	ful_01KSYGK32E7WQ4D5YNPM4C9H8C	ordful_01KSYGK33G6VFDC7F98TMQ1XJX	2026-05-31 09:57:18.319516+02	2026-05-31 09:57:18.319516+02	\N
order_01KSYNR3FQYDZ176SCBXMTC2CA	ful_01KSYNRY5QE6WC9XE86D6X2MPW	ordful_01KSYNRY69VA983WT8X1TXKBT8	2026-05-31 11:27:52.777061+02	2026-05-31 11:27:52.777061+02	\N
order_01KSYPW2RSZ248CCQ1F6HZEQJ5	ful_01KSYPWSFHJ0HXZSVH3G0SZ4WP	ordful_01KSYPWSG2A1NXZERWT5ZMQ0JM	2026-05-31 11:47:27.617527+02	2026-05-31 11:47:27.617527+02	\N
\.


--
-- Data for Name: order_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_item (id, order_id, version, item_id, quantity, raw_quantity, fulfilled_quantity, raw_fulfilled_quantity, shipped_quantity, raw_shipped_quantity, return_requested_quantity, raw_return_requested_quantity, return_received_quantity, raw_return_received_quantity, return_dismissed_quantity, raw_return_dismissed_quantity, written_off_quantity, raw_written_off_quantity, metadata, created_at, updated_at, deleted_at, delivered_quantity, raw_delivered_quantity, unit_price, raw_unit_price, compare_at_unit_price, raw_compare_at_unit_price) FROM stdin;
orditem_01KSWZ94QN9RAQQY75W2P8VGXQ	order_01KSWZ94QHBKV096ESCTPKNS2N	1	ordli_01KSWZ94QMZSFYTT7W2RETNS1N	1	{"value": "1", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-05-30 19:35:32.087+02	2026-05-30 19:35:32.087+02	\N	0	{"value": "0", "precision": 20}	\N	\N	\N	\N
orditem_01KSYGK34NNA5Y26H1WE1QYNF1	order_01KSWZ94QHBKV096ESCTPKNS2N	2	ordli_01KSWZ94QMZSFYTT7W2RETNS1N	1	{"value": "1", "precision": 20}	1	{"value": "1", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-05-31 09:57:18.361+02	2026-05-31 09:57:18.361+02	\N	0	{"value": "0", "precision": 20}	10000	{"value": "10000", "precision": 20}	\N	\N
orditem_01KSYNR3FR919B13Y09JX76G1A	order_01KSYNR3FQYDZ176SCBXMTC2CA	1	ordli_01KSYNR3FRS9WA22GY059T0G28	1	{"value": "1", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-05-31 11:27:25.432+02	2026-05-31 11:27:25.432+02	\N	0	{"value": "0", "precision": 20}	\N	\N	\N	\N
orditem_01KSYNRY6V9XTGWG7F9BKB4NG8	order_01KSYNR3FQYDZ176SCBXMTC2CA	2	ordli_01KSYNR3FRS9WA22GY059T0G28	1	{"value": "1", "precision": 20}	1	{"value": "1", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-05-31 11:27:52.797+02	2026-05-31 11:27:52.797+02	\N	0	{"value": "0", "precision": 20}	10000	{"value": "10000", "precision": 20}	\N	\N
orditem_01KSYPW2RSSQMBAB22E934NN7M	order_01KSYPW2RSZ248CCQ1F6HZEQJ5	1	ordli_01KSYPW2RSYNTHG25MJ844X3J6	3	{"value": "3", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-05-31 11:47:04.346+02	2026-05-31 11:47:04.346+02	\N	0	{"value": "0", "precision": 20}	\N	\N	\N	\N
orditem_01KSYPWSGPS613ME7BKY6QVZ0G	order_01KSYPW2RSZ248CCQ1F6HZEQJ5	2	ordli_01KSYPW2RSYNTHG25MJ844X3J6	3	{"value": "3", "precision": 20}	3	{"value": "3", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-05-31 11:47:27.644+02	2026-05-31 11:47:27.644+02	\N	0	{"value": "0", "precision": 20}	10000	{"value": "10000", "precision": 20}	\N	\N
orditem_01KSYQFJDFCW1H6R99WT04SG9X	order_01KSYPW2RSZ248CCQ1F6HZEQJ5	3	ordli_01KSYPW2RSYNTHG25MJ844X3J6	3	{"value": "3", "precision": 20}	3	{"value": "3", "precision": 20}	3	{"value": "3", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-05-31 11:57:42.963+02	2026-05-31 11:57:42.963+02	\N	0	{"value": "0", "precision": 20}	10000	{"value": "10000", "precision": 20}	\N	\N
orditem_01KSYQWJJ7KSSSSBH3AEDESVQJ	order_01KSYPW2RSZ248CCQ1F6HZEQJ5	4	ordli_01KSYPW2RSYNTHG25MJ844X3J6	3	{"value": "3", "precision": 20}	3	{"value": "3", "precision": 20}	3	{"value": "3", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-05-31 12:04:49.1+02	2026-05-31 12:04:49.1+02	\N	3	{"value": "3", "precision": 20}	10000	{"value": "10000", "precision": 20}	\N	\N
orditem_01KSYZ528KBD7SCXQ3WHB51ZEM	order_01KSYZ528J6XCKJY7DR20SPNTZ	1	ordli_01KSYZ528K7F7FE3YWG6T7C8QP	1	{"value": "1", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-05-31 14:11:47.348+02	2026-05-31 14:11:47.348+02	\N	0	{"value": "0", "precision": 20}	\N	\N	\N	\N
orditem_01KSYZ9NKPZD873D3RHSN7CW4H	order_01KSYZ9NKNR0ZFP1NHRRJ6C4H0	1	ordli_01KSYZ9NKPT3BD4SADFGXJ2HTE	1	{"value": "1", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-05-31 14:14:18.231+02	2026-05-31 14:14:18.231+02	\N	0	{"value": "0", "precision": 20}	\N	\N	\N	\N
orditem_01KSYZEHBKZG96VVYSWA1XKS0Y	order_01KSYZEHBJT6J0R02PCEWAQXYW	1	ordli_01KSYZEHBK57K0417M8YF43A9Q	2	{"value": "2", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-05-31 14:16:57.716+02	2026-05-31 14:16:57.716+02	\N	0	{"value": "0", "precision": 20}	\N	\N	\N	\N
orditem_01KSZ025AWK1Q3SY64S2BFNYD7	order_01KSZ025ATTT8ABSP8NXJK5XXH	1	ordli_01KSZ025AV3349EXAY89T9HR6J	1	{"value": "1", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-05-31 14:27:40.765+02	2026-05-31 14:27:40.765+02	\N	0	{"value": "0", "precision": 20}	\N	\N	\N	\N
orditem_01KSZ040QJGS4JRT4KBS9HFNFA	order_01KSZ040QG8CAWV63TQC132B9P	1	ordli_01KSZ040QHCMZVEYMKNPVQSEJD	1	{"value": "1", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-05-31 14:28:41.587+02	2026-05-31 14:28:41.587+02	\N	0	{"value": "0", "precision": 20}	\N	\N	\N	\N
orditem_01KSZ0VB1AC2MSRBED6ZFSM60M	order_01KSZ0VB193K4QY97BW6PNNHWE	1	ordli_01KSZ0VB1ADYXBFHF741VN7QWR	1	{"value": "1", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-05-31 14:41:25.803+02	2026-05-31 14:41:25.803+02	\N	0	{"value": "0", "precision": 20}	\N	\N	\N	\N
orditem_01KT121KWQQT12SMDGQS83BDQX	order_01KSWZ94QHBKV096ESCTPKNS2N	3	ordli_01KSWZ94QMZSFYTT7W2RETNS1N	1	{"value": "1", "precision": 20}	1	{"value": "1", "precision": 20}	1	{"value": "1", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-06-01 09:40:48.922+02	2026-06-01 09:40:48.922+02	\N	0	{"value": "0", "precision": 20}	10000	{"value": "10000", "precision": 20}	\N	\N
orditem_01KZSRKT0WMWGTCE6GGKYT6YR5	order_01KZSRKT0QNS81MFMA4G05RZ8E	1	ordli_01KZSRKT0TR6NSR1DY6XMVSJ9H	1	{"value": "1", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-08-12 03:15:29.182+02	2026-08-12 03:15:29.182+02	\N	0	{"value": "0", "precision": 20}	\N	\N	\N	\N
orditem_01KZSRPGTAXATQ2ZZSR8WW9H78	order_01KZSRPGT61RWGZEV4XWSST4DB	1	ordli_01KZSRPGT910TWMA1C33G9CGSG	2	{"value": "2", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-08-12 03:16:58.06+02	2026-08-12 03:16:58.06+02	\N	0	{"value": "0", "precision": 20}	\N	\N	\N	\N
orditem_01KZSRT94Q48EC8MB81GM6TKV6	order_01KZSRT94K7A6N76KXHBVTJKMJ	1	ordli_01KZSRT94PSJ2JMJCPVAVGRRXW	1	{"value": "1", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-08-12 03:19:01.273+02	2026-08-12 03:19:01.273+02	\N	0	{"value": "0", "precision": 20}	\N	\N	\N	\N
orditem_01KZSS4E0KWDK4C9TD14BDE8DK	order_01KZSS4E0E2TDSQ1CZW34GVH80	1	ordli_01KZSS4E0JRWCSEPV6GEEPV1E7	3	{"value": "3", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-08-12 03:24:33.942+02	2026-08-12 03:24:33.942+02	\N	0	{"value": "0", "precision": 20}	\N	\N	\N	\N
orditem_01KZSS713QCE86J7Q9XS3V1DVN	order_01KZSS713JEJG13A30NW7X2RR7	1	ordli_01KZSS713NAAN48S2BJ9EE2KXR	4	{"value": "4", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-08-12 03:25:59.033+02	2026-08-12 03:25:59.033+02	\N	0	{"value": "0", "precision": 20}	\N	\N	\N	\N
orditem_01KZTFBQSSJKT4BZ38BHDFXQBH	order_01KZTFBQSNE8M83ECV3F4F3K9J	1	ordli_01KZTFBQSQQ30XNDNFFXPEPV63	1	{"value": "1", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	\N	2026-08-12 09:53:02.012+02	2026-08-12 09:53:02.012+02	\N	0	{"value": "0", "precision": 20}	\N	\N	\N	\N
\.


--
-- Data for Name: order_line_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_line_item (id, totals_id, title, subtitle, thumbnail, variant_id, product_id, product_title, product_description, product_subtitle, product_type, product_collection, product_handle, variant_sku, variant_barcode, variant_title, variant_option_values, requires_shipping, is_discountable, is_tax_inclusive, compare_at_unit_price, raw_compare_at_unit_price, unit_price, raw_unit_price, metadata, created_at, updated_at, deleted_at, is_custom_price, product_type_id, is_giftcard) FROM stdin;
ordli_01KSWZ94QMZSFYTT7W2RETNS1N	\N	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-05-30 19:35:32.087+02	2026-05-30 19:35:32.087+02	\N	f	\N	f
ordli_01KSYNR3FRS9WA22GY059T0G28	\N	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-05-31 11:27:25.432+02	2026-05-31 11:27:25.432+02	\N	f	\N	f
ordli_01KSYPW2RSYNTHG25MJ844X3J6	\N	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-05-31 11:47:04.346+02	2026-05-31 11:47:04.346+02	\N	f	\N	f
ordli_01KSYZ528K7F7FE3YWG6T7C8QP	\N	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-05-31 14:11:47.347+02	2026-05-31 14:11:47.347+02	\N	f	\N	f
ordli_01KSYZ9NKPT3BD4SADFGXJ2HTE	\N	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-05-31 14:14:18.231+02	2026-05-31 14:14:18.231+02	\N	f	\N	f
ordli_01KSYZEHBK57K0417M8YF43A9Q	\N	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-05-31 14:16:57.716+02	2026-05-31 14:16:57.716+02	\N	f	\N	f
ordli_01KSZ025AV3349EXAY89T9HR6J	\N	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-05-31 14:27:40.765+02	2026-05-31 14:27:40.765+02	\N	f	\N	f
ordli_01KSZ040QHCMZVEYMKNPVQSEJD	\N	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-05-31 14:28:41.587+02	2026-05-31 14:28:41.587+02	\N	f	\N	f
ordli_01KSZ0VB1ADYXBFHF741VN7QWR	\N	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-05-31 14:41:25.803+02	2026-05-31 14:41:25.803+02	\N	f	\N	f
ordli_01KZSRKT0TR6NSR1DY6XMVSJ9H	\N	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-08-12 03:15:29.182+02	2026-08-12 03:15:29.182+02	\N	f	\N	f
ordli_01KZSRPGT910TWMA1C33G9CGSG	\N	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-08-12 03:16:58.06+02	2026-08-12 03:16:58.06+02	\N	f	\N	f
ordli_01KZSRT94PSJ2JMJCPVAVGRRXW	\N	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-08-12 03:19:01.273+02	2026-08-12 03:19:01.273+02	\N	f	\N	f
ordli_01KZSS4E0JRWCSEPV6GEEPV1E7	\N	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-08-12 03:24:33.941+02	2026-08-12 03:24:33.941+02	\N	f	\N	f
ordli_01KZSS713NAAN48S2BJ9EE2KXR	\N	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-08-12 03:25:59.033+02	2026-08-12 03:25:59.033+02	\N	f	\N	f
ordli_01KZTFBQSQQ30XNDNFFXPEPV63	\N	Ma saani	Rouge	http://localhost:9000/static/1779641482219-image.jpg	variant_01KSDEEB4X5XQS5EZAMWG8KH96	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	Hello	\N	\N	\N	ma-saani	\N	\N	Rouge	\N	t	t	f	\N	\N	10000	{"value": "10000", "precision": 20}	{}	2026-08-12 09:53:02.012+02	2026-08-12 09:53:02.012+02	\N	f	\N	f
\.


--
-- Data for Name: order_line_item_adjustment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_line_item_adjustment (id, description, promotion_id, code, amount, raw_amount, provider_id, created_at, updated_at, item_id, deleted_at, is_tax_inclusive, version) FROM stdin;
ordliadj_01KZSRKT0TK1ABXPP5CGMGQKDB	\N	promo_01KZSNVQVHV4YR8R403X1ZZPDG	FLASH-LP02E1	2000	{"value": "2000", "precision": 20}	\N	2026-08-12 03:15:29.183+02	2026-08-12 03:15:29.183+02	ordli_01KZSRKT0TR6NSR1DY6XMVSJ9H	\N	f	1
ordliadj_01KZSRPGT8CYN1BK8AQSY7TNEZ	\N	promo_01KZSNVQVHV4YR8R403X1ZZPDG	FLASH-LP02E1	4000	{"value": "4000", "precision": 20}	\N	2026-08-12 03:16:58.061+02	2026-08-12 03:16:58.061+02	ordli_01KZSRPGT910TWMA1C33G9CGSG	\N	f	1
ordliadj_01KZSRT94P829Y8MJDRPTF1NPX	\N	promo_01KZSNVQVHV4YR8R403X1ZZPDG	FLASH-LP02E1	2000	{"value": "2000", "precision": 20}	\N	2026-08-12 03:19:01.275+02	2026-08-12 03:19:01.275+02	ordli_01KZSRT94PSJ2JMJCPVAVGRRXW	\N	f	1
ordliadj_01KZSS4E0H5F0HC3JDN944FPG7	\N	promo_01KZSNVQVHV4YR8R403X1ZZPDG	FLASH-LP02E1	6000	{"value": "6000", "precision": 20}	\N	2026-08-12 03:24:33.943+02	2026-08-12 03:24:33.943+02	ordli_01KZSS4E0JRWCSEPV6GEEPV1E7	\N	f	1
ordliadj_01KZSS713NBRX02YN0YMX68S8N	\N	promo_01KZSNVQVHV4YR8R403X1ZZPDG	FLASH-LP02E1	8000	{"value": "8000", "precision": 20}	\N	2026-08-12 03:25:59.034+02	2026-08-12 03:25:59.034+02	ordli_01KZSS713NAAN48S2BJ9EE2KXR	\N	f	1
\.


--
-- Data for Name: order_line_item_tax_line; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_line_item_tax_line (id, description, tax_rate_id, code, rate, raw_rate, provider_id, created_at, updated_at, item_id, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_payment_collection; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_payment_collection (order_id, payment_collection_id, id, created_at, updated_at, deleted_at) FROM stdin;
order_01KSWZ94QHBKV096ESCTPKNS2N	pay_col_01KSWZ94EQ5D38QNM7MST6HWZG	ordpay_01KSWZ94VASAWWGNNR8RWFGG3V	2026-05-30 19:35:32.192124+02	2026-05-30 19:35:32.192124+02	\N
order_01KSYNR3FQYDZ176SCBXMTC2CA	pay_col_01KSYNR39BDXK25THEAVTSYRGS	ordpay_01KSYNR3GMP9C19AHFZ4PX5KRP	2026-05-31 11:27:25.456913+02	2026-05-31 11:27:25.456913+02	\N
order_01KSYPW2RSZ248CCQ1F6HZEQJ5	pay_col_01KSYPW2KYHN8K2GHSVKVXMBZG	ordpay_01KSYPW2T3HF6Y2RYEP53NR4CS	2026-05-31 11:47:04.384236+02	2026-05-31 11:47:04.384236+02	\N
order_01KSYZ528J6XCKJY7DR20SPNTZ	pay_col_01KSYZ51Q4494HTGSD1TJ8A5D2	ordpay_01KSYZ529RVPAW9FANJH07YYZX	2026-05-31 14:11:47.383208+02	2026-05-31 14:11:47.383208+02	\N
order_01KSYZ9NKNR0ZFP1NHRRJ6C4H0	pay_col_01KSYZ9NDFGXQM8FA9J9W7D3JD	ordpay_01KSYZ9NMN413QFFZ2CMZ3N5C7	2026-05-31 14:14:18.260371+02	2026-05-31 14:14:18.260371+02	\N
order_01KSYZEHBJT6J0R02PCEWAQXYW	pay_col_01KSYZEH789VJTB2YQF9KHSJWZ	ordpay_01KSYZEHCP1JKXJFBBZSHWYB1G	2026-05-31 14:16:57.747596+02	2026-05-31 14:16:57.747596+02	\N
order_01KSZ025ATTT8ABSP8NXJK5XXH	pay_col_01KSZ02556JBB1TV51D0S5K6Y9	ordpay_01KSZ025CQPAZKRB82Y2D8TVKT	2026-05-31 14:27:40.821927+02	2026-05-31 14:27:40.821927+02	\N
order_01KSZ040QG8CAWV63TQC132B9P	pay_col_01KSZ040JFEPH8MCEFB8KNTFRR	ordpay_01KSZ040RY80Z6CPY4J3W562WZ	2026-05-31 14:28:41.624157+02	2026-05-31 14:28:41.624157+02	\N
order_01KSZ0VB193K4QY97BW6PNNHWE	pay_col_01KSZ0VAW9SMZTJHEJ0T5M6QHJ	ordpay_01KSZ0VB299M8AT0BGPCD0QFFK	2026-05-31 14:41:25.832207+02	2026-05-31 14:41:25.832207+02	\N
order_01KT9CPZEAY25M28V9MKEET6A7	pay_col_01KT6M0W172PCB6JW5MG36TPT6	ordpay_01KT9CPZFXRV51FG6KC9MS6QG0	2026-06-04 15:21:10.140713+02	2026-06-04 15:21:10.214+02	2026-06-04 15:21:10.214+02
order_01KT9CQAG3DF5ZA2EV7DV4BQX0	pay_col_01KT6M0W172PCB6JW5MG36TPT6	ordpay_01KT9CQAH39B0WPJ50D20X3Q9B	2026-06-04 15:21:21.442769+02	2026-06-04 15:21:21.478+02	2026-06-04 15:21:21.478+02
order_01KT9CQP69M9BGSJPWFT94WPW2	pay_col_01KT6M0W172PCB6JW5MG36TPT6	ordpay_01KT9CQP7DYA0510R9T99S1MGF	2026-06-04 15:21:33.419385+02	2026-06-04 15:21:33.457+02	2026-06-04 15:21:33.457+02
order_01KT9CTS56P51FG4WXAG8CCTRD	pay_col_01KT6M0W172PCB6JW5MG36TPT6	ordpay_01KT9CTS5WZH1742B291TWWS3V	2026-06-04 15:23:14.747401+02	2026-06-04 15:23:14.775+02	2026-06-04 15:23:14.775+02
order_01KT9CXBGJ7DBRZ8ZJG8TARDTC	pay_col_01KT6M0W172PCB6JW5MG36TPT6	ordpay_01KT9CXBHN8QT6SV991HWPTQQE	2026-06-04 15:24:39.092445+02	2026-06-04 15:24:39.125+02	2026-06-04 15:24:39.125+02
order_01KTBF4WV33ZQZ0VVF4TZTS0GV	pay_col_01KT6M0W172PCB6JW5MG36TPT6	ordpay_01KTBF4WZA1R1WMWBA0YBSGV1V	2026-06-05 10:42:12.325099+02	2026-06-05 10:42:12.444+02	2026-06-05 10:42:12.443+02
order_01KZSRKT0QNS81MFMA4G05RZ8E	pay_col_01KZSRKCBR0ZN38RXKZRW228SQ	ordpay_01KZSRKT4QHHD9NQJQVB363VQF	2026-08-12 03:15:29.295079+02	2026-08-12 03:15:29.295079+02	\N
order_01KZSRPGT61RWGZEV4XWSST4DB	pay_col_01KZSRPGGP387KFPAG78BHCSAE	ordpay_01KZSRPGXPV9KQ1BJRH3A8JY1K	2026-08-12 03:16:58.163838+02	2026-08-12 03:16:58.163838+02	\N
order_01KZSRT94K7A6N76KXHBVTJKMJ	pay_col_01KZSRT8Y4S969FXBXAS1AY8VQ	ordpay_01KZSRT97GZQTJ5XPX563AP8E0	2026-08-12 03:19:01.348709+02	2026-08-12 03:19:01.348709+02	\N
order_01KZSS4E0E2TDSQ1CZW34GVH80	pay_col_01KZSS4DSR9SKHCTMM0M8PPCSR	ordpay_01KZSS4E3QYR388HDXDEZ9RE7J	2026-08-12 03:24:34.024832+02	2026-08-12 03:24:34.024832+02	\N
order_01KZSS713JEJG13A30NW7X2RR7	pay_col_01KZSS70X45RCV80Q6K7RJCTRD	ordpay_01KZSS716J3T2K6B8PCJ7KZGQV	2026-08-12 03:25:59.114658+02	2026-08-12 03:25:59.114658+02	\N
order_01KZTFBQSNE8M83ECV3F4F3K9J	pay_col_01KZTFBQH0TFC3M9BSP14R8WY4	ordpay_01KZTFBQWQGFPQR2Z5A7NCWZJ9	2026-08-12 09:53:02.095134+02	2026-08-12 09:53:02.095134+02	\N
\.


--
-- Data for Name: order_promotion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_promotion (order_id, promotion_id, id, created_at, updated_at, deleted_at) FROM stdin;
order_01KZSRKT0QNS81MFMA4G05RZ8E	promo_01KZSNVQVHV4YR8R403X1ZZPDG	orderpromo_01KZSRKT3Z3NCCG601BA4KH606	2026-08-12 03:15:29.276979+02	2026-08-12 03:15:29.276979+02	\N
order_01KZSRPGT61RWGZEV4XWSST4DB	promo_01KZSNVQVHV4YR8R403X1ZZPDG	orderpromo_01KZSRPGX9J0C1R6K6CAWZXBNF	2026-08-12 03:16:58.148893+02	2026-08-12 03:16:58.148893+02	\N
order_01KZSRT94K7A6N76KXHBVTJKMJ	promo_01KZSNVQVHV4YR8R403X1ZZPDG	orderpromo_01KZSRT97JZQDYZ97P9Q8CP5MM	2026-08-12 03:19:01.348685+02	2026-08-12 03:19:01.348685+02	\N
order_01KZSS4E0E2TDSQ1CZW34GVH80	promo_01KZSNVQVHV4YR8R403X1ZZPDG	orderpromo_01KZSS4E3NX9QX3X80QRN73AAZ	2026-08-12 03:24:34.024792+02	2026-08-12 03:24:34.024792+02	\N
order_01KZSS713JEJG13A30NW7X2RR7	promo_01KZSNVQVHV4YR8R403X1ZZPDG	orderpromo_01KZSS716H5AVPVRGZH8ZBNKHY	2026-08-12 03:25:59.114626+02	2026-08-12 03:25:59.114626+02	\N
\.


--
-- Data for Name: order_shipping; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_shipping (id, order_id, version, shipping_method_id, created_at, updated_at, deleted_at, return_id, claim_id, exchange_id) FROM stdin;
ordspmv_01KSWZ94QHR80M3JQY2P0W1PRP	order_01KSWZ94QHBKV096ESCTPKNS2N	1	ordsm_01KSWZ94QH21W05NRTQ1PE9SQX	2026-05-30 19:35:32.088+02	2026-05-30 19:35:32.088+02	\N	\N	\N	\N
ordspmv_01KSYGK34N2BNH957X9XPC7KXP	order_01KSWZ94QHBKV096ESCTPKNS2N	2	ordsm_01KSWZ94QH21W05NRTQ1PE9SQX	2026-05-30 19:35:32.088+02	2026-05-30 19:35:32.088+02	\N	\N	\N	\N
ordspmv_01KSYNR3FQA9SACNVMAGMNCV7D	order_01KSYNR3FQYDZ176SCBXMTC2CA	1	ordsm_01KSYNR3FQF4ZB1VYTJ3EEK73Z	2026-05-31 11:27:25.432+02	2026-05-31 11:27:25.432+02	\N	\N	\N	\N
ordspmv_01KSYNRY6VB6KC30NZ2XNZYBZC	order_01KSYNR3FQYDZ176SCBXMTC2CA	2	ordsm_01KSYNR3FQF4ZB1VYTJ3EEK73Z	2026-05-31 11:27:25.432+02	2026-05-31 11:27:25.432+02	\N	\N	\N	\N
ordspmv_01KSYPW2RS4EB0R8AJTPA66RR3	order_01KSYPW2RSZ248CCQ1F6HZEQJ5	1	ordsm_01KSYPW2RSY87XY4039XCBD79C	2026-05-31 11:47:04.346+02	2026-05-31 11:47:04.346+02	\N	\N	\N	\N
ordspmv_01KSYPWSGQ01RKPG9H9HQAX1ZP	order_01KSYPW2RSZ248CCQ1F6HZEQJ5	2	ordsm_01KSYPW2RSY87XY4039XCBD79C	2026-05-31 11:47:04.346+02	2026-05-31 11:47:04.346+02	\N	\N	\N	\N
ordspmv_01KSYQFJDFQ8WTQHS3GHKHNGKD	order_01KSYPW2RSZ248CCQ1F6HZEQJ5	3	ordsm_01KSYPW2RSY87XY4039XCBD79C	2026-05-31 11:47:04.346+02	2026-05-31 11:47:04.346+02	\N	\N	\N	\N
ordspmv_01KSYQWJJ7FDCVWHA3CKV8RACF	order_01KSYPW2RSZ248CCQ1F6HZEQJ5	4	ordsm_01KSYPW2RSY87XY4039XCBD79C	2026-05-31 11:47:04.346+02	2026-05-31 11:47:04.346+02	\N	\N	\N	\N
ordspmv_01KSYZ528J8E84DDF1DRBVYZCB	order_01KSYZ528J6XCKJY7DR20SPNTZ	1	ordsm_01KSYZ528JM5SJSW6PM2VE73HM	2026-05-31 14:11:47.348+02	2026-05-31 14:11:47.348+02	\N	\N	\N	\N
ordspmv_01KSYZ9NKN1ZHZTASEMSFKA5XA	order_01KSYZ9NKNR0ZFP1NHRRJ6C4H0	1	ordsm_01KSYZ9NKNEE3MJ77QX1VDD3MY	2026-05-31 14:14:18.231+02	2026-05-31 14:14:18.231+02	\N	\N	\N	\N
ordspmv_01KSYZEHBJB4X1J8KPACMZTT4K	order_01KSYZEHBJT6J0R02PCEWAQXYW	1	ordsm_01KSYZEHBJWKPQ069H49FQE745	2026-05-31 14:16:57.716+02	2026-05-31 14:16:57.716+02	\N	\N	\N	\N
ordspmv_01KSZ025ATHMNW7MW3VXQBTVSP	order_01KSZ025ATTT8ABSP8NXJK5XXH	1	ordsm_01KSZ025ATXQB3PT813F2QMEJN	2026-05-31 14:27:40.766+02	2026-05-31 14:27:40.766+02	\N	\N	\N	\N
ordspmv_01KSZ040QGGC6PN01RS7570QN9	order_01KSZ040QG8CAWV63TQC132B9P	1	ordsm_01KSZ040QG0PCF3Y40GWSH0G6Q	2026-05-31 14:28:41.587+02	2026-05-31 14:28:41.587+02	\N	\N	\N	\N
ordspmv_01KSZ0VB19XBWN0QHFTJ6ZWHF8	order_01KSZ0VB193K4QY97BW6PNNHWE	1	ordsm_01KSZ0VB19HJS991XEYPQ1NNTW	2026-05-31 14:41:25.803+02	2026-05-31 14:41:25.803+02	\N	\N	\N	\N
ordspmv_01KT121KWQPYJ7RJ56FDMKZJRZ	order_01KSWZ94QHBKV096ESCTPKNS2N	3	ordsm_01KSWZ94QH21W05NRTQ1PE9SQX	2026-05-30 19:35:32.088+02	2026-05-30 19:35:32.088+02	\N	\N	\N	\N
ordspmv_01KZSRKT0QWHBAR0FJM6B8B7HG	order_01KZSRKT0QNS81MFMA4G05RZ8E	1	ordsm_01KZSRKT0QBH538BJ09KVM2WZP	2026-08-12 03:15:29.183+02	2026-08-12 03:15:29.183+02	\N	\N	\N	\N
ordspmv_01KZSRPGT5K76TSQ720BBYSHA6	order_01KZSRPGT61RWGZEV4XWSST4DB	1	ordsm_01KZSRPGT5W2HDHZDJTP0N7JCX	2026-08-12 03:16:58.061+02	2026-08-12 03:16:58.061+02	\N	\N	\N	\N
ordspmv_01KZSRT94K54V107QG2WWZPDE8	order_01KZSRT94K7A6N76KXHBVTJKMJ	1	ordsm_01KZSRT94KFA9Z2S0QVRRVYZPQ	2026-08-12 03:19:01.275+02	2026-08-12 03:19:01.275+02	\N	\N	\N	\N
ordspmv_01KZSS4E0EHAZR8X0BWGVS1EKQ	order_01KZSS4E0E2TDSQ1CZW34GVH80	1	ordsm_01KZSS4E0E2V1BPBJ3QQ5X04R7	2026-08-12 03:24:33.943+02	2026-08-12 03:24:33.943+02	\N	\N	\N	\N
ordspmv_01KZSS713JAQYEMB5583BP4NRD	order_01KZSS713JEJG13A30NW7X2RR7	1	ordsm_01KZSS713JKKB24JFSSRR6398E	2026-08-12 03:25:59.034+02	2026-08-12 03:25:59.034+02	\N	\N	\N	\N
ordspmv_01KZTFBQSM0GF5TFDYBHKAH533	order_01KZTFBQSNE8M83ECV3F4F3K9J	1	ordsm_01KZTFBQSM0SPVVKX5G190DFPZ	2026-08-12 09:53:02.013+02	2026-08-12 09:53:02.013+02	\N	\N	\N	\N
\.


--
-- Data for Name: order_shipping_method; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_shipping_method (id, name, description, amount, raw_amount, is_tax_inclusive, shipping_option_id, data, metadata, created_at, updated_at, deleted_at, is_custom_amount) FROM stdin;
ordsm_01KSWZ94QH21W05NRTQ1PE9SQX	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-05-30 19:35:32.088+02	2026-05-30 19:35:32.088+02	\N	f
ordsm_01KSYNR3FQF4ZB1VYTJ3EEK73Z	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-05-31 11:27:25.432+02	2026-05-31 11:27:25.432+02	\N	f
ordsm_01KSYPW2RSY87XY4039XCBD79C	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-05-31 11:47:04.346+02	2026-05-31 11:47:04.346+02	\N	f
ordsm_01KSYZ528JM5SJSW6PM2VE73HM	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-05-31 14:11:47.348+02	2026-05-31 14:11:47.348+02	\N	f
ordsm_01KSYZ9NKNEE3MJ77QX1VDD3MY	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-05-31 14:14:18.231+02	2026-05-31 14:14:18.231+02	\N	f
ordsm_01KSYZEHBJWKPQ069H49FQE745	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-05-31 14:16:57.716+02	2026-05-31 14:16:57.716+02	\N	f
ordsm_01KSZ025ATXQB3PT813F2QMEJN	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-05-31 14:27:40.765+02	2026-05-31 14:27:40.765+02	\N	f
ordsm_01KSZ040QG0PCF3Y40GWSH0G6Q	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-05-31 14:28:41.587+02	2026-05-31 14:28:41.587+02	\N	f
ordsm_01KSZ0VB19HJS991XEYPQ1NNTW	LV1	\N	100	{"value": "100", "precision": 20}	f	so_01KSWK0MGHVTE3D3GG9BEB4SYS	{}	\N	2026-05-31 14:41:25.803+02	2026-05-31 14:41:25.803+02	\N	f
ordsm_01KZSRKT0QBH538BJ09KVM2WZP	Standart	\N	10	{"value": "10", "precision": 20}	f	so_01KTAFNNF59QWDVTRF6X6WJ9RG	{}	\N	2026-08-12 03:15:29.183+02	2026-08-12 03:15:29.183+02	\N	f
ordsm_01KZSRPGT5W2HDHZDJTP0N7JCX	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-08-12 03:16:58.061+02	2026-08-12 03:16:58.061+02	\N	f
ordsm_01KZSRT94KFA9Z2S0QVRRVYZPQ	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-08-12 03:19:01.274+02	2026-08-12 03:19:01.274+02	\N	f
ordsm_01KZSS4E0E2V1BPBJ3QQ5X04R7	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-08-12 03:24:33.943+02	2026-08-12 03:24:33.943+02	\N	f
ordsm_01KZSS713JKKB24JFSSRR6398E	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-08-12 03:25:59.033+02	2026-08-12 03:25:59.033+02	\N	f
ordsm_01KZTFBQSM0SPVVKX5G190DFPZ	express	\N	30	{"value": "30", "precision": 20}	f	so_01KTAF58PA2C6DZQG2GAR40V2H	{}	\N	2026-08-12 09:53:02.013+02	2026-08-12 09:53:02.013+02	\N	f
\.


--
-- Data for Name: order_shipping_method_adjustment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_shipping_method_adjustment (id, description, promotion_id, code, amount, raw_amount, provider_id, created_at, updated_at, shipping_method_id, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_shipping_method_tax_line; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_shipping_method_tax_line (id, description, tax_rate_id, code, rate, raw_rate, provider_id, created_at, updated_at, shipping_method_id, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_summary; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_summary (id, order_id, version, totals, created_at, updated_at, deleted_at) FROM stdin;
ordsum_01KSWZ94QF6YSG3JGZ0FNKC6TY	order_01KSWZ94QHBKV096ESCTPKNS2N	1	{"paid_total": 10100, "raw_paid_total": {"value": "10100", "precision": 20}, "refunded_total": 0, "accounting_total": 10100, "credit_line_total": 0, "transaction_total": 10100, "pending_difference": 0, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 10100, "original_order_total": 10100, "raw_accounting_total": {"value": "10100", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "10100", "precision": 20}, "raw_pending_difference": {"value": "0", "precision": 20}, "raw_current_order_total": {"value": "10100", "precision": 20}, "raw_original_order_total": {"value": "10100", "precision": 20}}	2026-05-30 19:35:32.088+02	2026-05-30 19:39:57.557+02	\N
ordsum_01KSYGK34NCCZBHEFMG4399JEX	order_01KSWZ94QHBKV096ESCTPKNS2N	2	{"paid_total": 10100, "raw_paid_total": {"value": "10100", "precision": 20}, "refunded_total": 0, "accounting_total": 10100, "credit_line_total": 0, "transaction_total": 10100, "pending_difference": 0, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 10100, "original_order_total": 10100, "raw_accounting_total": {"value": "10100", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "10100", "precision": 20}, "raw_pending_difference": {"value": "0", "precision": 20}, "raw_current_order_total": {"value": "10100", "precision": 20}, "raw_original_order_total": {"value": "10100", "precision": 20}}	2026-05-31 09:57:18.361+02	2026-05-31 09:57:18.361+02	\N
ordsum_01KSYNR3FP27D5Q9CBFH87HP63	order_01KSYNR3FQYDZ176SCBXMTC2CA	1	{"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 10100, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 10100, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 10100, "original_order_total": 10100, "raw_accounting_total": {"value": "10100", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "10100", "precision": 20}, "raw_current_order_total": {"value": "10100", "precision": 20}, "raw_original_order_total": {"value": "10100", "precision": 20}}	2026-05-31 11:27:25.432+02	2026-05-31 11:27:25.432+02	\N
ordsum_01KSYNRY6VZAWPG6Z4XG8PT6Q2	order_01KSYNR3FQYDZ176SCBXMTC2CA	2	{"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 10100, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 10100, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 10100, "original_order_total": 10100, "raw_accounting_total": {"value": "10100", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "10100", "precision": 20}, "raw_current_order_total": {"value": "10100", "precision": 20}, "raw_original_order_total": {"value": "10100", "precision": 20}}	2026-05-31 11:27:52.797+02	2026-05-31 11:27:52.797+02	\N
ordsum_01KSYPW2RS39GMN4GMP5VWQJB9	order_01KSYPW2RSZ248CCQ1F6HZEQJ5	1	{"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 30100, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 30100, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 30100, "original_order_total": 30100, "raw_accounting_total": {"value": "30100", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "30100", "precision": 20}, "raw_current_order_total": {"value": "30100", "precision": 20}, "raw_original_order_total": {"value": "30100", "precision": 20}}	2026-05-31 11:47:04.346+02	2026-05-31 11:47:04.346+02	\N
ordsum_01KSYPWSGPMD80754XKYSHGCFE	order_01KSYPW2RSZ248CCQ1F6HZEQJ5	2	{"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 30100, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 30100, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 30100, "original_order_total": 30100, "raw_accounting_total": {"value": "30100", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "30100", "precision": 20}, "raw_current_order_total": {"value": "30100", "precision": 20}, "raw_original_order_total": {"value": "30100", "precision": 20}}	2026-05-31 11:47:27.644+02	2026-05-31 11:47:27.644+02	\N
ordsum_01KSYQFJDFWV0XWBMQ67TQBQ7Z	order_01KSYPW2RSZ248CCQ1F6HZEQJ5	3	{"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 30100, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 30100, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 30100, "original_order_total": 30100, "raw_accounting_total": {"value": "30100", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "30100", "precision": 20}, "raw_current_order_total": {"value": "30100", "precision": 20}, "raw_original_order_total": {"value": "30100", "precision": 20}}	2026-05-31 11:57:42.963+02	2026-05-31 11:57:42.963+02	\N
ordsum_01KSYQWJJ7FG60HQ3J472DKRR6	order_01KSYPW2RSZ248CCQ1F6HZEQJ5	4	{"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 30100, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 30100, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 30100, "original_order_total": 30100, "raw_accounting_total": {"value": "30100", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "30100", "precision": 20}, "raw_current_order_total": {"value": "30100", "precision": 20}, "raw_original_order_total": {"value": "30100", "precision": 20}}	2026-05-31 12:04:49.1+02	2026-05-31 12:04:49.1+02	\N
ordsum_01KSYZ528JQGWNDJW19R8T8QAY	order_01KSYZ528J6XCKJY7DR20SPNTZ	1	{"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 10100, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 10100, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 10100, "original_order_total": 10100, "raw_accounting_total": {"value": "10100", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "10100", "precision": 20}, "raw_current_order_total": {"value": "10100", "precision": 20}, "raw_original_order_total": {"value": "10100", "precision": 20}}	2026-05-31 14:11:47.348+02	2026-05-31 14:11:47.348+02	\N
ordsum_01KSYZ9NKMSZEXP8XVQ1DKQBTB	order_01KSYZ9NKNR0ZFP1NHRRJ6C4H0	1	{"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 10100, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 10100, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 10100, "original_order_total": 10100, "raw_accounting_total": {"value": "10100", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "10100", "precision": 20}, "raw_current_order_total": {"value": "10100", "precision": 20}, "raw_original_order_total": {"value": "10100", "precision": 20}}	2026-05-31 14:14:18.231+02	2026-05-31 14:14:18.231+02	\N
ordsum_01KSYZEHBHNAEFG30W39V1SNPM	order_01KSYZEHBJT6J0R02PCEWAQXYW	1	{"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 20100, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 20100, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 20100, "original_order_total": 20100, "raw_accounting_total": {"value": "20100", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "20100", "precision": 20}, "raw_current_order_total": {"value": "20100", "precision": 20}, "raw_original_order_total": {"value": "20100", "precision": 20}}	2026-05-31 14:16:57.716+02	2026-05-31 14:16:57.716+02	\N
ordsum_01KSZ025AS864BFSC7KWPT83C0	order_01KSZ025ATTT8ABSP8NXJK5XXH	1	{"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 10100, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 10100, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 10100, "original_order_total": 10100, "raw_accounting_total": {"value": "10100", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "10100", "precision": 20}, "raw_current_order_total": {"value": "10100", "precision": 20}, "raw_original_order_total": {"value": "10100", "precision": 20}}	2026-05-31 14:27:40.765+02	2026-05-31 14:27:40.765+02	\N
ordsum_01KSZ040QFRQKK5GNG0AXB6WME	order_01KSZ040QG8CAWV63TQC132B9P	1	{"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 10100, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 10100, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 10100, "original_order_total": 10100, "raw_accounting_total": {"value": "10100", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "10100", "precision": 20}, "raw_current_order_total": {"value": "10100", "precision": 20}, "raw_original_order_total": {"value": "10100", "precision": 20}}	2026-05-31 14:28:41.587+02	2026-05-31 14:28:41.587+02	\N
ordsum_01KSZ0VB19QSCF5E7HV4NXVPKC	order_01KSZ0VB193K4QY97BW6PNNHWE	1	{"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 10100, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 10100, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 10100, "original_order_total": 10100, "raw_accounting_total": {"value": "10100", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "10100", "precision": 20}, "raw_current_order_total": {"value": "10100", "precision": 20}, "raw_original_order_total": {"value": "10100", "precision": 20}}	2026-05-31 14:41:25.803+02	2026-05-31 14:41:25.803+02	\N
ordsum_01KT121KWQ3WD28ZCN6RJW3AFG	order_01KSWZ94QHBKV096ESCTPKNS2N	3	{"paid_total": 10100, "raw_paid_total": {"value": "10100", "precision": 20}, "refunded_total": 0, "accounting_total": 10100, "credit_line_total": 0, "transaction_total": 10100, "pending_difference": 0, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 10100, "original_order_total": 10100, "raw_accounting_total": {"value": "10100", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "10100", "precision": 20}, "raw_pending_difference": {"value": "0", "precision": 20}, "raw_current_order_total": {"value": "10100", "precision": 20}, "raw_original_order_total": {"value": "10100", "precision": 20}}	2026-06-01 09:40:48.922+02	2026-06-01 09:40:48.922+02	\N
ordsum_01KZSRKT0N6MZ3DVA7MMN48H07	order_01KZSRKT0QNS81MFMA4G05RZ8E	1	{"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 8010, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 8010, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 8010, "original_order_total": 8010, "raw_accounting_total": {"value": "8010", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "8010", "precision": 20}, "raw_current_order_total": {"value": "8010", "precision": 20}, "raw_original_order_total": {"value": "8010", "precision": 20}}	2026-08-12 03:15:29.182+02	2026-08-12 03:15:29.182+02	\N
ordsum_01KZSRPGT3348J7VDRGBKBHFZ8	order_01KZSRPGT61RWGZEV4XWSST4DB	1	{"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 16030, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 16030, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 16030, "original_order_total": 16030, "raw_accounting_total": {"value": "16030", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "16030", "precision": 20}, "raw_current_order_total": {"value": "16030", "precision": 20}, "raw_original_order_total": {"value": "16030", "precision": 20}}	2026-08-12 03:16:58.061+02	2026-08-12 03:16:58.061+02	\N
ordsum_01KZSRT94HHVATMS8GJR3MMEYS	order_01KZSRT94K7A6N76KXHBVTJKMJ	1	{"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 8030, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 8030, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 8030, "original_order_total": 8030, "raw_accounting_total": {"value": "8030", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "8030", "precision": 20}, "raw_current_order_total": {"value": "8030", "precision": 20}, "raw_original_order_total": {"value": "8030", "precision": 20}}	2026-08-12 03:19:01.274+02	2026-08-12 03:19:01.274+02	\N
ordsum_01KZSS4E0CWXD9SQEJA6Z8W7DH	order_01KZSS4E0E2TDSQ1CZW34GVH80	1	{"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 24030, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 24030, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 24030, "original_order_total": 24030, "raw_accounting_total": {"value": "24030", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "24030", "precision": 20}, "raw_current_order_total": {"value": "24030", "precision": 20}, "raw_original_order_total": {"value": "24030", "precision": 20}}	2026-08-12 03:24:33.942+02	2026-08-12 03:24:33.942+02	\N
ordsum_01KZSS713FEVG42VC9CDFE0X0N	order_01KZSS713JEJG13A30NW7X2RR7	1	{"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 32030, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 32030, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 32030, "original_order_total": 32030, "raw_accounting_total": {"value": "32030", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "32030", "precision": 20}, "raw_current_order_total": {"value": "32030", "precision": 20}, "raw_original_order_total": {"value": "32030", "precision": 20}}	2026-08-12 03:25:59.033+02	2026-08-12 03:25:59.033+02	\N
ordsum_01KZTFBQSJQPSAGR51KKWN731X	order_01KZTFBQSNE8M83ECV3F4F3K9J	1	{"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 10030, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 10030, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 10030, "original_order_total": 10030, "raw_accounting_total": {"value": "10030", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "10030", "precision": 20}, "raw_current_order_total": {"value": "10030", "precision": 20}, "raw_original_order_total": {"value": "10030", "precision": 20}}	2026-08-12 09:53:02.012+02	2026-08-12 09:53:02.012+02	\N
\.


--
-- Data for Name: order_transaction; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_transaction (id, order_id, version, amount, raw_amount, currency_code, reference, reference_id, created_at, updated_at, deleted_at, return_id, claim_id, exchange_id) FROM stdin;
ordtrx_01KSWZH7Z9QV231MJ0K3ZX3Y5G	order_01KSWZ94QHBKV096ESCTPKNS2N	1	10100	{"value": "10100", "precision": 20}	usd	capture	capt_01KSWZH7X99HJ1W6FV6MSAQTJS	2026-05-30 19:39:57.557+02	2026-05-30 19:39:57.557+02	\N	\N	\N	\N
\.


--
-- Data for Name: payment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payment (id, amount, raw_amount, currency_code, provider_id, data, created_at, updated_at, deleted_at, captured_at, canceled_at, payment_collection_id, payment_session_id, metadata) FROM stdin;
pay_01KSWZ94X29003ZASHHKTR2F82	10100	{"value": "10100", "precision": 20}	usd	pp_system_default	{}	2026-05-30 19:35:32.258+02	2026-05-30 19:39:57.501+02	\N	2026-05-30 19:39:57.491+02	\N	pay_col_01KSWZ94EQ5D38QNM7MST6HWZG	payses_01KSWZ94J7CY6729VA2K78547P	\N
pay_01KSYNR3H0EB9N08VBM3N9ABER	10100	{"value": "10100", "precision": 20}	usd	pp_system_default	{}	2026-05-31 11:27:25.473+02	2026-05-31 11:27:25.473+02	\N	\N	\N	pay_col_01KSYNR39BDXK25THEAVTSYRGS	payses_01KSYNR3C7W7WCX69YZ5NTDW78	\N
pay_01KSYPW2TJ8VVH3T192JFTCY0T	30100	{"value": "30100", "precision": 20}	usd	pp_system_default	{}	2026-05-31 11:47:04.402+02	2026-05-31 11:47:04.402+02	\N	\N	\N	pay_col_01KSYPW2KYHN8K2GHSVKVXMBZG	payses_01KSYPW2P5TNXWN70T3BHAVG19	\N
pay_01KSYZ52AEDJGQCBGMSXZ7XKDX	10100	{"value": "10100", "precision": 20}	usd	pp_system_default	{}	2026-05-31 14:11:47.406+02	2026-05-31 14:11:47.406+02	\N	\N	\N	pay_col_01KSYZ51Q4494HTGSD1TJ8A5D2	payses_01KSYZ5226WMATPAM6S2DGJZ1X	\N
pay_01KSYZ9NNA8EQ14BMK6E7MNDC7	10100	{"value": "10100", "precision": 20}	usd	pp_system_default	{}	2026-05-31 14:14:18.282+02	2026-05-31 14:14:18.282+02	\N	\N	\N	pay_col_01KSYZ9NDFGXQM8FA9J9W7D3JD	payses_01KSYZ9NF83CBN9KVKS0KCRXH5	\N
pay_01KSYZEHD9BB7NEYMCT84B2GS3	20100	{"value": "20100", "precision": 20}	usd	pp_system_default	{}	2026-05-31 14:16:57.769+02	2026-05-31 14:16:57.769+02	\N	\N	\N	pay_col_01KSYZEH789VJTB2YQF9KHSJWZ	payses_01KSYZEH8VP23SR6003EK0R1NB	\N
pay_01KSZ025DAWZY8EZTKGVKCP4WF	10100	{"value": "10100", "precision": 20}	usd	pp_system_default	{}	2026-05-31 14:27:40.842+02	2026-05-31 14:27:40.842+02	\N	\N	\N	pay_col_01KSZ02556JBB1TV51D0S5K6Y9	payses_01KSZ025785Q26NP2ZV88X2G2R	\N
pay_01KSZ040SH1YB5YYXKR79CT90D	10100	{"value": "10100", "precision": 20}	usd	pp_system_default	{}	2026-05-31 14:28:41.649+02	2026-05-31 14:28:41.649+02	\N	\N	\N	pay_col_01KSZ040JFEPH8MCEFB8KNTFRR	payses_01KSZ040MJ95CZEF9WZ1X1B5J6	\N
pay_01KSZ0VB2Z32092MARSGV4ENPQ	10100	{"value": "10100", "precision": 20}	usd	pp_system_default	{}	2026-05-31 14:41:25.856+02	2026-05-31 14:41:25.856+02	\N	\N	\N	pay_col_01KSZ0VAW9SMZTJHEJ0T5M6QHJ	payses_01KSZ0VAYF75NZARP8Z2MSRSCG	\N
pay_01KZSRKT5XAPW8KSY4NN5EY5F7	8010	{"value": "8010", "precision": 20}	usd	pp_system_default	{}	2026-08-12 03:15:29.341+02	2026-08-12 03:15:29.341+02	\N	\N	\N	pay_col_01KZSRKCBR0ZN38RXKZRW228SQ	payses_01KZSRKHSVGE72XB2VXD0MEYPV	\N
pay_01KZSRPGYZDH0013CX12PB6GK9	16030	{"value": "16030", "precision": 20}	usd	pp_system_default	{}	2026-08-12 03:16:58.208+02	2026-08-12 03:16:58.208+02	\N	\N	\N	pay_col_01KZSRPGGP387KFPAG78BHCSAE	payses_01KZSRPGKP4ZB0RQ0ZWC5ME5QK	\N
pay_01KZSRT98YC1V5529MKZPPZBJ4	8030	{"value": "8030", "precision": 20}	usd	pp_system_default	{}	2026-08-12 03:19:01.406+02	2026-08-12 03:19:01.406+02	\N	\N	\N	pay_col_01KZSRT8Y4S969FXBXAS1AY8VQ	payses_01KZSRT9054GSW999FVN1PKBWS	\N
pay_01KZSS4E56PSBZKNSZEZ8HXSQ0	24030	{"value": "24030", "precision": 20}	usd	pp_system_default	{}	2026-08-12 03:24:34.086+02	2026-08-12 03:24:34.086+02	\N	\N	\N	pay_col_01KZSS4DSR9SKHCTMM0M8PPCSR	payses_01KZSS4DVP2PD662JDW0F1Y20M	\N
pay_01KZSS717W1REVF4QFPKFPR76T	32030	{"value": "32030", "precision": 20}	usd	pp_system_default	{}	2026-08-12 03:25:59.165+02	2026-08-12 03:25:59.165+02	\N	\N	\N	pay_col_01KZSS70X45RCV80Q6K7RJCTRD	payses_01KZSS70Z4TKA5XXMS4717VCS9	\N
pay_01KZTFBQY33N4XHGZTQFX80JHB	10030	{"value": "10030", "precision": 20}	usd	pp_system_default	{}	2026-08-12 09:53:02.147+02	2026-08-12 09:53:02.147+02	\N	\N	\N	pay_col_01KZTFBQH0TFC3M9BSP14R8WY4	payses_01KZTFBQMMZF8A7W5F687T289F	\N
\.


--
-- Data for Name: payment_collection; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payment_collection (id, currency_code, amount, raw_amount, authorized_amount, raw_authorized_amount, captured_amount, raw_captured_amount, refunded_amount, raw_refunded_amount, created_at, updated_at, deleted_at, completed_at, status, metadata) FROM stdin;
pay_col_01KSWZ94EQ5D38QNM7MST6HWZG	usd	10100	{"value": "10100", "precision": 20}	10100	{"value": "10100", "precision": 20}	10100	{"value": "10100", "precision": 20}	0	{"value": "0", "precision": 20}	2026-05-30 19:35:31.799+02	2026-05-30 19:39:57.525+02	\N	2026-05-30 19:39:57.52+02	completed	\N
pay_col_01KSYNR39BDXK25THEAVTSYRGS	usd	10100	{"value": "10100", "precision": 20}	10100	{"value": "10100", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	2026-05-31 11:27:25.227+02	2026-05-31 11:27:25.482+02	\N	\N	authorized	\N
pay_col_01KSYPW2KYHN8K2GHSVKVXMBZG	usd	30100	{"value": "30100", "precision": 20}	30100	{"value": "30100", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	2026-05-31 11:47:04.191+02	2026-05-31 11:47:04.414+02	\N	\N	authorized	\N
pay_col_01KSYZ51Q4494HTGSD1TJ8A5D2	usd	10100	{"value": "10100", "precision": 20}	10100	{"value": "10100", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	2026-05-31 14:11:46.788+02	2026-05-31 14:11:47.438+02	\N	\N	authorized	\N
pay_col_01KSYZ9NDFGXQM8FA9J9W7D3JD	usd	10100	{"value": "10100", "precision": 20}	10100	{"value": "10100", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	2026-05-31 14:14:18.031+02	2026-05-31 14:14:18.292+02	\N	\N	authorized	\N
pay_col_01KSYZEH789VJTB2YQF9KHSJWZ	usd	20100	{"value": "20100", "precision": 20}	20100	{"value": "20100", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	2026-05-31 14:16:57.577+02	2026-05-31 14:16:57.779+02	\N	\N	authorized	\N
pay_col_01KSZ02556JBB1TV51D0S5K6Y9	usd	10100	{"value": "10100", "precision": 20}	10100	{"value": "10100", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	2026-05-31 14:27:40.582+02	2026-05-31 14:27:40.856+02	\N	\N	authorized	\N
pay_col_01KSZ040JFEPH8MCEFB8KNTFRR	usd	10100	{"value": "10100", "precision": 20}	10100	{"value": "10100", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	2026-05-31 14:28:41.423+02	2026-05-31 14:28:41.662+02	\N	\N	authorized	\N
pay_col_01KSZ0VAW9SMZTJHEJ0T5M6QHJ	usd	10100	{"value": "10100", "precision": 20}	10100	{"value": "10100", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	2026-05-31 14:41:25.642+02	2026-05-31 14:41:25.869+02	\N	\N	authorized	\N
pay_col_01KVDNF9Z3Q1QC438AY9WDDYMG	usd	30	{"value": "30", "precision": 20}	\N	\N	\N	\N	\N	\N	2026-06-18 17:26:55.459+02	2026-06-19 05:55:32.452+02	\N	\N	not_paid	\N
pay_col_01KZSRKCBR0ZN38RXKZRW228SQ	usd	8010	{"value": "8010", "precision": 20}	8010	{"value": "8010", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	2026-08-12 03:15:15.193+02	2026-08-12 03:15:29.374+02	\N	\N	authorized	\N
pay_col_01KZSRPGGP387KFPAG78BHCSAE	usd	16030	{"value": "16030", "precision": 20}	16030	{"value": "16030", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	2026-08-12 03:16:57.751+02	2026-08-12 03:16:58.23+02	\N	\N	authorized	\N
pay_col_01KZSRT8Y4S969FXBXAS1AY8VQ	usd	8030	{"value": "8030", "precision": 20}	8030	{"value": "8030", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	2026-08-12 03:19:01.06+02	2026-08-12 03:19:01.43+02	\N	\N	authorized	\N
pay_col_01KZSS4DSR9SKHCTMM0M8PPCSR	usd	24030	{"value": "24030", "precision": 20}	24030	{"value": "24030", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	2026-08-12 03:24:33.721+02	2026-08-12 03:24:34.108+02	\N	\N	authorized	\N
pay_col_01KT6M0W172PCB6JW5MG36TPT6	usd	20030	{"value": "20030", "precision": 20}	\N	\N	\N	\N	\N	\N	2026-06-03 13:31:11.016+02	2026-06-06 14:32:02.969+02	\N	\N	not_paid	\N
pay_col_01KZSS70X45RCV80Q6K7RJCTRD	usd	32030	{"value": "32030", "precision": 20}	32030	{"value": "32030", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	2026-08-12 03:25:58.821+02	2026-08-12 03:25:59.188+02	\N	\N	authorized	\N
pay_col_01KZTFBQH0TFC3M9BSP14R8WY4	usd	10030	{"value": "10030", "precision": 20}	10030	{"value": "10030", "precision": 20}	0	{"value": "0", "precision": 20}	0	{"value": "0", "precision": 20}	2026-08-12 09:53:01.729+02	2026-08-12 09:53:02.179+02	\N	\N	authorized	\N
pay_col_01KVAYBKQD47ZD40RDE63AACSW	usd	1930	{"value": "1930", "precision": 20}	\N	\N	\N	\N	\N	\N	2026-06-17 16:04:28.269+02	2026-08-13 23:02:25.092+02	\N	\N	not_paid	\N
pay_col_01KVF22BN4S82ZGGZQ3ESSFBBV	usd	830	{"value": "830", "precision": 20}	\N	\N	\N	\N	\N	\N	2026-06-19 06:26:17.124+02	2026-07-01 00:10:00.954+02	\N	\N	not_paid	\N
pay_col_01KXDHMRCGTBWARECQFFF32YNB	usd	15210	{"value": "15210", "precision": 20}	\N	\N	\N	\N	\N	\N	2026-07-13 12:51:23.408+02	2026-08-15 18:53:40.011+02	\N	\N	not_paid	\N
\.


--
-- Data for Name: payment_collection_payment_providers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payment_collection_payment_providers (payment_collection_id, payment_provider_id) FROM stdin;
\.


--
-- Data for Name: payment_provider; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payment_provider (id, is_enabled, created_at, updated_at, deleted_at) FROM stdin;
pp_stripe-oxxo_stripe	t	2026-06-03 16:51:35.426+02	2026-06-03 16:51:35.426+02	\N
pp_stripe-promptpay_stripe	t	2026-06-03 16:51:35.426+02	2026-06-03 16:51:35.426+02	\N
pp_stripe-przelewy24_stripe	t	2026-06-03 16:51:35.426+02	2026-06-03 16:51:35.426+02	\N
pp_stripe_stripe	t	2026-06-03 16:51:35.426+02	2026-06-03 16:51:35.426+02	\N
pp_stripe-ideal_stripe	t	2026-06-03 16:51:35.426+02	2026-06-03 16:51:35.426+02	\N
pp_stripe-giropay_stripe	t	2026-06-03 16:51:35.426+02	2026-06-03 16:51:35.426+02	\N
pp_stripe-blik_stripe	t	2026-06-03 16:51:35.426+02	2026-06-03 16:51:35.426+02	\N
pp_stripe-bancontact_stripe	t	2026-06-03 16:51:35.426+02	2026-06-03 16:51:35.426+02	\N
pp_kashflow_kashflow	t	2026-06-03 16:51:35.426+02	2026-06-03 16:51:35.426+02	\N
pp_system_default	t	2026-06-03 16:51:35.426+02	2026-06-03 16:51:35.426+02	\N
\.


--
-- Data for Name: payment_session; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payment_session (id, currency_code, amount, raw_amount, provider_id, data, context, status, authorized_at, payment_collection_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
payses_01KSWZ94J7CY6729VA2K78547P	usd	10100	{"value": "10100", "precision": 20}	pp_system_default	{}	{"customer": {"id": "cus_01KSVPWBFY9T5MZXK47CYD788Q", "email": "princelulinda10@gmail.com", "phone": "888888", "metadata": null, "addresses": [{"id": "cuaddr_01KSVPXDMC7X1M67T9QW4EJSHR", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line 1", "address_2": "", "last_name": "-", "created_at": "2026-05-30T05:50:04.940Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-30T05:50:04.940Z", "customer_id": "cus_01KSVPWBFY9T5MZXK47CYD788Q", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}], "last_name": "-", "first_name": "prince", "company_name": null, "account_holders": [], "billing_address": {"id": "cuaddr_01KSVPXDMC7X1M67T9QW4EJSHR", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line 1", "address_2": "", "last_name": "-", "created_at": "2026-05-30T05:50:04.940Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-30T05:50:04.940Z", "customer_id": "cus_01KSVPWBFY9T5MZXK47CYD788Q", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}}, "account_holder": {"id": "acchld_01KSWZ94HFGMXS8Z8D3YATDQRX", "data": {}, "email": "princelulinda10@gmail.com", "metadata": null, "created_at": "2026-05-30T17:35:31.888Z", "deleted_at": null, "updated_at": "2026-05-30T17:35:31.888Z", "external_id": "cus_01KSVPWBFY9T5MZXK47CYD788Q", "provider_id": "pp_system_default"}}	authorized	2026-05-30 19:35:32.251+02	pay_col_01KSWZ94EQ5D38QNM7MST6HWZG	{}	2026-05-30 19:35:31.912+02	2026-05-30 19:35:32.259+02	\N
payses_01KSYNR3C7W7WCX69YZ5NTDW78	usd	10100	{"value": "10100", "precision": 20}	pp_system_default	{}	{"customer": {"id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "email": "princelulinda32@gmail.com", "phone": "76777777", "metadata": null, "addresses": [{"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}], "last_name": "lulinda", "first_name": "prince", "company_name": null, "account_holders": [], "billing_address": {"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}}, "account_holder": {"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}}	authorized	2026-05-31 11:27:25.471+02	pay_col_01KSYNR39BDXK25THEAVTSYRGS	{}	2026-05-31 11:27:25.319+02	2026-05-31 11:27:25.473+02	\N
payses_01KSYPW2P5TNXWN70T3BHAVG19	usd	30100	{"value": "30100", "precision": 20}	pp_system_default	{}	{"customer": {"id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "email": "princelulinda32@gmail.com", "phone": "76777777", "metadata": null, "addresses": [{"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}], "last_name": "lulinda", "first_name": "prince", "company_name": null, "account_holders": [{"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}], "billing_address": {"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}}, "account_holder": {"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}}	authorized	2026-05-31 11:47:04.4+02	pay_col_01KSYPW2KYHN8K2GHSVKVXMBZG	{}	2026-05-31 11:47:04.261+02	2026-05-31 11:47:04.402+02	\N
payses_01KSYZ5226WMATPAM6S2DGJZ1X	usd	10100	{"value": "10100", "precision": 20}	pp_system_default	{}	{"customer": {"id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "email": "princelulinda32@gmail.com", "phone": "76777777", "metadata": null, "addresses": [{"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}], "last_name": "lulinda", "first_name": "prince", "company_name": null, "account_holders": [{"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}], "billing_address": {"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}}, "account_holder": {"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}}	authorized	2026-05-31 14:11:47.402+02	pay_col_01KSYZ51Q4494HTGSD1TJ8A5D2	{}	2026-05-31 14:11:47.143+02	2026-05-31 14:11:47.406+02	\N
payses_01KSYZ9NF83CBN9KVKS0KCRXH5	usd	10100	{"value": "10100", "precision": 20}	pp_system_default	{}	{"customer": {"id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "email": "princelulinda32@gmail.com", "phone": "76777777", "metadata": null, "addresses": [{"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}], "last_name": "lulinda", "first_name": "prince", "company_name": null, "account_holders": [{"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}], "billing_address": {"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}}, "account_holder": {"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}}	authorized	2026-05-31 14:14:18.279+02	pay_col_01KSYZ9NDFGXQM8FA9J9W7D3JD	{}	2026-05-31 14:14:18.088+02	2026-05-31 14:14:18.282+02	\N
payses_01KZSRPGKP4ZB0RQ0ZWC5ME5QK	usd	16030	{"value": "16030", "precision": 20}	pp_system_default	{}	{}	authorized	2026-08-12 03:16:58.202+02	pay_col_01KZSRPGGP387KFPAG78BHCSAE	{}	2026-08-12 03:16:57.847+02	2026-08-12 03:16:58.208+02	\N
payses_01KZSS4DVP2PD662JDW0F1Y20M	usd	24030	{"value": "24030", "precision": 20}	pp_system_default	{}	{}	authorized	2026-08-12 03:24:34.081+02	pay_col_01KZSS4DSR9SKHCTMM0M8PPCSR	{}	2026-08-12 03:24:33.782+02	2026-08-12 03:24:34.087+02	\N
payses_01KSYZEH8VP23SR6003EK0R1NB	usd	20100	{"value": "20100", "precision": 20}	pp_system_default	{}	{"customer": {"id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "email": "princelulinda32@gmail.com", "phone": "76777777", "metadata": null, "addresses": [{"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}], "last_name": "lulinda", "first_name": "prince", "company_name": null, "account_holders": [{"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}], "billing_address": {"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}}, "account_holder": {"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}}	authorized	2026-05-31 14:16:57.767+02	pay_col_01KSYZEH789VJTB2YQF9KHSJWZ	{}	2026-05-31 14:16:57.627+02	2026-05-31 14:16:57.769+02	\N
payses_01KSZ025785Q26NP2ZV88X2G2R	usd	10100	{"value": "10100", "precision": 20}	pp_system_default	{}	{"customer": {"id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "email": "princelulinda32@gmail.com", "phone": "76777777", "metadata": null, "addresses": [{"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}], "last_name": "lulinda", "first_name": "prince", "company_name": null, "account_holders": [{"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}], "billing_address": {"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}}, "account_holder": {"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}}	authorized	2026-05-31 14:27:40.838+02	pay_col_01KSZ02556JBB1TV51D0S5K6Y9	{}	2026-05-31 14:27:40.648+02	2026-05-31 14:27:40.843+02	\N
payses_01KSZ040MJ95CZEF9WZ1X1B5J6	usd	10100	{"value": "10100", "precision": 20}	pp_system_default	{}	{"customer": {"id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "email": "princelulinda32@gmail.com", "phone": "76777777", "metadata": null, "addresses": [{"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}], "last_name": "lulinda", "first_name": "prince", "company_name": null, "account_holders": [{"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}], "billing_address": {"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}}, "account_holder": {"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}}	authorized	2026-05-31 14:28:41.647+02	pay_col_01KSZ040JFEPH8MCEFB8KNTFRR	{}	2026-05-31 14:28:41.49+02	2026-05-31 14:28:41.649+02	\N
payses_01KSZ0VAYF75NZARP8Z2MSRSCG	usd	10100	{"value": "10100", "precision": 20}	pp_system_default	{}	{"customer": {"id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "email": "princelulinda32@gmail.com", "phone": "76777777", "metadata": null, "addresses": [{"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}], "last_name": "lulinda", "first_name": "prince", "company_name": null, "account_holders": [{"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}], "billing_address": {"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}}, "account_holder": {"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}}	authorized	2026-05-31 14:41:25.85+02	pay_col_01KSZ0VAW9SMZTJHEJ0T5M6QHJ	{}	2026-05-31 14:41:25.712+02	2026-05-31 14:41:25.856+02	\N
payses_01KZSRKHSVGE72XB2VXD0MEYPV	usd	8010	{"value": "8010", "precision": 20}	pp_system_default	{}	{}	authorized	2026-08-12 03:15:29.334+02	pay_col_01KZSRKCBR0ZN38RXKZRW228SQ	{}	2026-08-12 03:15:20.763+02	2026-08-12 03:15:29.342+02	\N
payses_01KZSRT9054GSW999FVN1PKBWS	usd	8030	{"value": "8030", "precision": 20}	pp_system_default	{}	{}	authorized	2026-08-12 03:19:01.4+02	pay_col_01KZSRT8Y4S969FXBXAS1AY8VQ	{}	2026-08-12 03:19:01.126+02	2026-08-12 03:19:01.407+02	\N
payses_01KZSS70Z4TKA5XXMS4717VCS9	usd	32030	{"value": "32030", "precision": 20}	pp_system_default	{}	{}	authorized	2026-08-12 03:25:59.159+02	pay_col_01KZSS70X45RCV80Q6K7RJCTRD	{}	2026-08-12 03:25:58.884+02	2026-08-12 03:25:59.165+02	\N
payses_01KZTFBQMMZF8A7W5F687T289F	usd	10030	{"value": "10030", "precision": 20}	pp_system_default	{}	{"customer": {"id": "cus_01KZTFASX63451FWPYQZST4A8M", "email": "referraltest_1786521151@example.com", "phone": null, "metadata": null, "addresses": [], "last_name": "Test", "first_name": "Referred", "company_name": null, "account_holders": []}, "account_holder": {"id": "acchld_01KZTFBQKTM9HP0RTPEARR5QAZ", "data": {}, "email": "referraltest_1786521151@example.com", "metadata": null, "created_at": "2026-08-12T07:53:01.818Z", "deleted_at": null, "updated_at": "2026-08-12T07:53:01.818Z", "external_id": "cus_01KZTFASX63451FWPYQZST4A8M", "provider_id": "pp_system_default"}}	authorized	2026-08-12 09:53:02.141+02	pay_col_01KZTFBQH0TFC3M9BSP14R8WY4	{}	2026-08-12 09:53:01.844+02	2026-08-12 09:53:02.148+02	\N
\.


--
-- Data for Name: price; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.price (id, title, price_set_id, currency_code, raw_amount, rules_count, created_at, updated_at, deleted_at, price_list_id, amount, min_quantity, max_quantity, raw_min_quantity, raw_max_quantity) FROM stdin;
price_01KVANBJ08YCHVV7M3MBNXH9MB	\N	pset_01KVANBJ09PZRD5ZM52KW8DW8J	eur	{"value": "150", "precision": 20}	0	2026-06-17 13:27:09.321+02	2026-06-17 13:27:09.321+02	\N	\N	150	50	10000	{"value": "50", "precision": 20}	{"value": "10000", "precision": 20}
price_01KWTKZBPNV5VFY1ESSWG1JGPK	\N	pset_01KWTKZBPN5HPVGKXTQXEEG2Q3	bif	{"value": "1000000", "precision": 20}	0	2026-07-06 04:26:33.813+02	2026-07-06 04:26:33.813+02	\N	\N	1000000	\N	\N	\N	\N
price_01KWTKZBPNZ14DT3CW07TX9567	\N	pset_01KWTKZBPN5HPVGKXTQXEEG2Q3	usd	{"value": "2020", "precision": 20}	0	2026-07-06 04:26:33.814+02	2026-07-06 04:26:33.814+02	\N	\N	2020	\N	\N	\N	\N
price_01KWTKZBPN59H42NC63Q6HN9WS	\N	pset_01KWTKZBPNPY6S1ZFFZK6NXSTR	bif	{"value": "1000000", "precision": 20}	0	2026-07-06 04:26:33.814+02	2026-07-06 04:26:33.814+02	\N	\N	1000000	\N	\N	\N	\N
price_01KSCR9ECHNYZXZFRV710YJNPE	\N	pset_01KSCR9ECHE40GY2K2Z5RKJPRB	eur	{"value": "10", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	10	\N	\N	\N	\N
price_01KSCR9ECHZYY2SAJVKQEWCQKM	\N	pset_01KSCR9ECHE40GY2K2Z5RKJPRB	usd	{"value": "15", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	15	\N	\N	\N	\N
price_01KSCR9ECHSQ6F7K9ZBTHBA062	\N	pset_01KSCR9ECHJZD63PJ02VHCNE2C	eur	{"value": "10", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	10	\N	\N	\N	\N
price_01KSCR9ECH3H4S5J656SEDN8RJ	\N	pset_01KSCR9ECHJZD63PJ02VHCNE2C	usd	{"value": "15", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	15	\N	\N	\N	\N
price_01KSCR9ECH99BK2C55FWCH8G76	\N	pset_01KSCR9ECHAE8KQBHZ663MV2PJ	eur	{"value": "10", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	10	\N	\N	\N	\N
price_01KSCR9ECH0SCG8CSX7PCF3A4E	\N	pset_01KSCR9ECHAE8KQBHZ663MV2PJ	usd	{"value": "15", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	15	\N	\N	\N	\N
price_01KSCR9ECHB5NSBE4B97DK7XWJ	\N	pset_01KSCR9ECHXG21SJRGHCHR5G6W	eur	{"value": "10", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	10	\N	\N	\N	\N
price_01KSCR9ECH3KH0AXTE4KWM8TG8	\N	pset_01KSCR9ECHXG21SJRGHCHR5G6W	usd	{"value": "15", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	15	\N	\N	\N	\N
price_01KSCR9ECH2915J11YVPS6KMSC	\N	pset_01KSCR9ECH59RXB1EYQD7C92QR	eur	{"value": "10", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	10	\N	\N	\N	\N
price_01KSCR9ECHF7R0ENME4C5378DX	\N	pset_01KSCR9ECH59RXB1EYQD7C92QR	usd	{"value": "15", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	15	\N	\N	\N	\N
price_01KSCR9ECHQRK8V452XE4V4A99	\N	pset_01KSCR9ECH0WA5W8B6HBTATXXS	eur	{"value": "10", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	10	\N	\N	\N	\N
price_01KSCR9ECHRT16WEHCYPK53TV9	\N	pset_01KSCR9ECH0WA5W8B6HBTATXXS	usd	{"value": "15", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	15	\N	\N	\N	\N
price_01KSCR9ECHWPBD61X9NYHADF49	\N	pset_01KSCR9ECHG3AQVY3E7N1JYSPK	eur	{"value": "10", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	10	\N	\N	\N	\N
price_01KSCR9ECHTTNYSYRBCD3CKSH5	\N	pset_01KSCR9ECHG3AQVY3E7N1JYSPK	usd	{"value": "15", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	15	\N	\N	\N	\N
price_01KSCR9ECH6HZG5R5ZZ9BK43K5	\N	pset_01KSCR9ECJD3F4M0ATYW79596N	eur	{"value": "10", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	10	\N	\N	\N	\N
price_01KSCR9ECJTGS36JJTPCXXCY37	\N	pset_01KSCR9ECJD3F4M0ATYW79596N	usd	{"value": "15", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	15	\N	\N	\N	\N
price_01KSCR9ECJXR25AZMF53DPQBWD	\N	pset_01KSCR9ECJ24G1ANC2YGZ4T2VP	eur	{"value": "10", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	10	\N	\N	\N	\N
price_01KSCR9ECJDHC7APMJJFMRVWDR	\N	pset_01KSCR9ECJ24G1ANC2YGZ4T2VP	usd	{"value": "15", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	15	\N	\N	\N	\N
price_01KSCR9ECJYX5X17GHPGZJ4AZM	\N	pset_01KSCR9ECJD177T8XAPQWQFPYA	eur	{"value": "10", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	10	\N	\N	\N	\N
price_01KSCR9ECJBTM3HMX7QN51MSAW	\N	pset_01KSCR9ECJD177T8XAPQWQFPYA	usd	{"value": "15", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	15	\N	\N	\N	\N
price_01KSCR9ECJ0NK5JY56CGA0HYM0	\N	pset_01KSCR9ECJ1YF8H2NHK8JST4SC	eur	{"value": "10", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	10	\N	\N	\N	\N
price_01KSCR9ECJ3F9TB2CA9EMRVMB5	\N	pset_01KSCR9ECJ1YF8H2NHK8JST4SC	usd	{"value": "15", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	15	\N	\N	\N	\N
price_01KSCR9ECJC106B46K867PTFE6	\N	pset_01KSCR9ECJXJ0V6RMB5B6DY6CQ	eur	{"value": "10", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	10	\N	\N	\N	\N
price_01KSCR9ECJFPY4GPS3Z17YDW2Y	\N	pset_01KSCR9ECJXJ0V6RMB5B6DY6CQ	usd	{"value": "15", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	15	\N	\N	\N	\N
price_01KSCR9ECJCRW7M3F3RBC1D3YN	\N	pset_01KSCR9ECJNKJHQ3GEK4BKBWTV	eur	{"value": "10", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	10	\N	\N	\N	\N
price_01KSCR9ECJ960J4MA65SBDPE9H	\N	pset_01KSCR9ECJNKJHQ3GEK4BKBWTV	usd	{"value": "15", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	15	\N	\N	\N	\N
price_01KSCR9ECJMWFHWQ78G3Z2P6HA	\N	pset_01KSCR9ECJ1GZ29MKTKB6Y4N8P	eur	{"value": "10", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	10	\N	\N	\N	\N
price_01KSCR9ECJDZ308TZ5J2ZAT29Q	\N	pset_01KSCR9ECJ1GZ29MKTKB6Y4N8P	usd	{"value": "15", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	15	\N	\N	\N	\N
price_01KSCR9ECJY11E9HKYBR4F5TBC	\N	pset_01KSCR9ECJ0JGFPNPMPC6NG8N2	eur	{"value": "10", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	10	\N	\N	\N	\N
price_01KSCR9ECJ7RP3AAXR9PAHYVXG	\N	pset_01KSCR9ECJ0JGFPNPMPC6NG8N2	usd	{"value": "15", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	15	\N	\N	\N	\N
price_01KSCR9ECJEDQQQJZTYPDCR8VF	\N	pset_01KSCR9ECJ1RY8AB7QRXEEHW56	eur	{"value": "10", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	10	\N	\N	\N	\N
price_01KSCR9ECJA9721BFDZ3KPEKE2	\N	pset_01KSCR9ECJ1RY8AB7QRXEEHW56	usd	{"value": "15", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	15	\N	\N	\N	\N
price_01KSCR9ECJG1EWYVQBFZAVGEKS	\N	pset_01KSCR9ECJEZEHBK43XZZQ5VSW	eur	{"value": "10", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	10	\N	\N	\N	\N
price_01KSCR9ECJFQCJ39BT3PHD9JSZ	\N	pset_01KSCR9ECJEZEHBK43XZZQ5VSW	usd	{"value": "15", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	15	\N	\N	\N	\N
price_01KSCR9ECJS24MYKQSBT65JWJN	\N	pset_01KSCR9ECKQ26RMJM2G8KSW22X	eur	{"value": "10", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	10	\N	\N	\N	\N
price_01KSCR9ECJH30VKK6K1AK0NXJG	\N	pset_01KSCR9ECKQ26RMJM2G8KSW22X	usd	{"value": "15", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	15	\N	\N	\N	\N
price_01KSCR9ECK2M0PFP4G8VCVRFV7	\N	pset_01KSCR9ECKWY6XV6NFT0PXZHS3	eur	{"value": "10", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	10	\N	\N	\N	\N
price_01KSCR9ECKGM9515Y0VZ5C6ZDN	\N	pset_01KSCR9ECKWY6XV6NFT0PXZHS3	usd	{"value": "15", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	15	\N	\N	\N	\N
price_01KSCR9ECKP0SXV3DJR7H67VX4	\N	pset_01KSCR9ECKT191MKK8JV695GZM	eur	{"value": "10", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	10	\N	\N	\N	\N
price_01KWTKZBPN9G7W654PDEQTYM49	\N	pset_01KWTKZBPNPY6S1ZFFZK6NXSTR	usd	{"value": "2020", "precision": 20}	0	2026-07-06 04:26:33.814+02	2026-07-06 04:26:33.814+02	\N	\N	2020	\N	\N	\N	\N
price_01KSCR9ECKPPX55S9AMAQJ31G6	\N	pset_01KSCR9ECKT191MKK8JV695GZM	usd	{"value": "15", "precision": 20}	0	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N	\N	15	\N	\N	\N	\N
price_01KSDEEB5G31A12K2K1XKW8TZ7	\N	pset_01KSDEEB5GG42PTYFK4AVTZ6R1	eur	{"value": "10000", "precision": 20}	0	2026-05-24 18:52:40.241+02	2026-05-24 18:52:40.241+02	\N	\N	10000	\N	\N	\N	\N
price_01KSDEEB5G6Z0D04MVJC38TJPM	\N	pset_01KSDEEB5GG42PTYFK4AVTZ6R1	usd	{"value": "10000", "precision": 20}	0	2026-05-24 18:52:40.241+02	2026-05-24 18:52:40.241+02	\N	\N	10000	\N	\N	\N	\N
price_01KSDEEB5H4AJ4CJ40EY9FJFTC	\N	pset_01KSDEEB5HM8D6TN7EBYJHBRZ4	eur	{"value": "10000", "precision": 20}	0	2026-05-24 18:52:40.241+02	2026-05-24 18:52:40.241+02	\N	\N	10000	\N	\N	\N	\N
price_01KSDEEB5HQ06E0B59WWH92SMV	\N	pset_01KSDEEB5HM8D6TN7EBYJHBRZ4	usd	{"value": "10000", "precision": 20}	0	2026-05-24 18:52:40.241+02	2026-05-24 18:52:40.241+02	\N	\N	10000	\N	\N	\N	\N
price_01KSH2A90Q5KNDBDXXMM0PZTFY	\N	pset_01KSH2A90QGA5K2VSPJ7S60MDE	eur	{"value": "10000", "precision": 20}	0	2026-05-26 04:37:41.783+02	2026-05-26 04:37:41.783+02	\N	\N	10000	\N	\N	\N	\N
price_01KSCR9E8R8EAN9VPQPD7A2PK0	\N	pset_01KSCR9E8SESZKQR1E3J6NBEQ4	usd	{"value": "10", "precision": 20}	0	2026-05-24 12:25:30.905+02	2026-05-30 15:30:55.261+02	2026-05-30 15:30:55.252+02	\N	10	\N	\N	\N	\N
price_01KSCR9E8RZ82CZW71YDBJXPGH	\N	pset_01KSCR9E8SESZKQR1E3J6NBEQ4	eur	{"value": "10", "precision": 20}	0	2026-05-24 12:25:30.905+02	2026-05-30 15:30:55.261+02	2026-05-30 15:30:55.252+02	\N	10	\N	\N	\N	\N
price_01KSCR9E8SJXGFJJZ82RTKQG73	\N	pset_01KSCR9E8SESZKQR1E3J6NBEQ4	eur	{"value": "10", "precision": 20}	1	2026-05-24 12:25:30.905+02	2026-05-30 15:30:55.261+02	2026-05-30 15:30:55.252+02	\N	10	\N	\N	\N	\N
price_01KSCR9E8SE40DX0K6W9845JSE	\N	pset_01KSCR9E8SQ6D9GFMMRAVSVXWW	usd	{"value": "10", "precision": 20}	0	2026-05-24 12:25:30.906+02	2026-05-30 15:30:55.281+02	2026-05-30 15:30:55.252+02	\N	10	\N	\N	\N	\N
price_01KSCR9E8SP51Z3YZYG5JS49DQ	\N	pset_01KSCR9E8SQ6D9GFMMRAVSVXWW	eur	{"value": "10", "precision": 20}	0	2026-05-24 12:25:30.906+02	2026-05-30 15:30:55.281+02	2026-05-30 15:30:55.252+02	\N	10	\N	\N	\N	\N
price_01KSCR9E8S2CNZ5YA3C1F5CGB7	\N	pset_01KSCR9E8SQ6D9GFMMRAVSVXWW	eur	{"value": "10", "precision": 20}	1	2026-05-24 12:25:30.906+02	2026-05-30 15:30:55.281+02	2026-05-30 15:30:55.252+02	\N	10	\N	\N	\N	\N
price_01KTAC4W682EMDWS7TYTMN2DXB	\N	pset_01KTAC4W6AE91XR91GSTBWTHBY	eur	{"value": "1", "precision": 20}	0	2026-06-05 00:30:31.371+02	2026-06-05 00:35:51.972+02	2026-06-05 00:35:51.965+02	\N	1	\N	\N	\N	\N
price_01KT156V3T18CJFV3VRJVP1GS1	\N	pset_01KT156V3VBFXRVV4Q11J8X3XT	eur	{"value": "150", "precision": 20}	0	2026-06-01 10:36:05.887+02	2026-06-01 10:36:05.887+02	\N	\N	150	\N	\N	\N	\N
price_01KT156V3TWH59X3Z7JSJASYK2	\N	pset_01KT156V3VBFXRVV4Q11J8X3XT	usd	{"value": "150", "precision": 20}	0	2026-06-01 10:36:05.888+02	2026-06-01 10:36:05.888+02	\N	\N	150	\N	\N	\N	\N
price_01KT156V3VQTFYGA9GA8C9ME31	\N	pset_01KT156V3VSWX8PMXA8DKS19M8	eur	{"value": "150", "precision": 20}	0	2026-06-01 10:36:05.888+02	2026-06-01 10:36:05.888+02	\N	\N	150	\N	\N	\N	\N
price_01KT156V3VB1PAQKFF98R9NJZX	\N	pset_01KT156V3VSWX8PMXA8DKS19M8	usd	{"value": "150", "precision": 20}	0	2026-06-01 10:36:05.888+02	2026-06-01 10:36:05.888+02	\N	\N	150	\N	\N	\N	\N
price_01KT156V3VGWD0FTEH9ERSB79B	\N	pset_01KT156V3VMAZHWFFK682434N8	eur	{"value": "150", "precision": 20}	0	2026-06-01 10:36:05.888+02	2026-06-01 10:36:05.888+02	\N	\N	150	\N	\N	\N	\N
price_01KT156V3V48B121T9RSJ36ST7	\N	pset_01KT156V3VMAZHWFFK682434N8	usd	{"value": "150", "precision": 20}	0	2026-06-01 10:36:05.888+02	2026-06-01 10:36:05.888+02	\N	\N	150	\N	\N	\N	\N
price_01KT156V3V1W8Y9QMHN9F8M7C6	\N	pset_01KT156V3WNZEM2ZPB9FZXE16S	eur	{"value": "150", "precision": 20}	0	2026-06-01 10:36:05.888+02	2026-06-01 10:36:05.888+02	\N	\N	150	\N	\N	\N	\N
price_01KT156V3VANV9B8Y3N0QVD0C6	\N	pset_01KT156V3WNZEM2ZPB9FZXE16S	usd	{"value": "150", "precision": 20}	0	2026-06-01 10:36:05.888+02	2026-06-01 10:36:05.888+02	\N	\N	150	\N	\N	\N	\N
price_01KT156V3WC0A5CC449P0857G0	\N	pset_01KT156V3WTFAP7TW72AJS9F1E	eur	{"value": "150", "precision": 20}	0	2026-06-01 10:36:05.888+02	2026-06-01 10:36:05.888+02	\N	\N	150	\N	\N	\N	\N
price_01KT156V3W87JG7YT63CJTET46	\N	pset_01KT156V3WTFAP7TW72AJS9F1E	usd	{"value": "150", "precision": 20}	0	2026-06-01 10:36:05.888+02	2026-06-01 10:36:05.888+02	\N	\N	150	\N	\N	\N	\N
price_01KT156V3W2G99N4SSFDVY3XAD	\N	pset_01KT156V3WN800MMRWMSF4T0P4	eur	{"value": "150", "precision": 20}	0	2026-06-01 10:36:05.888+02	2026-06-01 10:36:05.888+02	\N	\N	150	\N	\N	\N	\N
price_01KT156V3WZ1BD16J1EX96ZHH1	\N	pset_01KT156V3WN800MMRWMSF4T0P4	usd	{"value": "150", "precision": 20}	0	2026-06-01 10:36:05.888+02	2026-06-01 10:36:05.888+02	\N	\N	150	\N	\N	\N	\N
price_01KT156V3WYEZM416KZ7EJJ51M	\N	pset_01KT156V3W3NDDMBH6632Q7VTP	eur	{"value": "150", "precision": 20}	0	2026-06-01 10:36:05.888+02	2026-06-01 10:36:05.888+02	\N	\N	150	\N	\N	\N	\N
price_01KT156V3WZ948XDYCEA07SQCG	\N	pset_01KT156V3W3NDDMBH6632Q7VTP	usd	{"value": "150", "precision": 20}	0	2026-06-01 10:36:05.888+02	2026-06-01 10:36:05.888+02	\N	\N	150	\N	\N	\N	\N
price_01KT156V3XENCTZ64ADRK7FTVP	\N	pset_01KT156V3X95FXBAB3JK6R7ABP	eur	{"value": "150", "precision": 20}	0	2026-06-01 10:36:05.888+02	2026-06-01 10:36:05.888+02	\N	\N	150	\N	\N	\N	\N
price_01KT156V3XVYNFVQ5PA1YBAZT1	\N	pset_01KT156V3X95FXBAB3JK6R7ABP	usd	{"value": "150", "precision": 20}	0	2026-06-01 10:36:05.888+02	2026-06-01 10:36:05.888+02	\N	\N	150	\N	\N	\N	\N
price_01KT156V3XJGKRCMCTVAWYZ3M0	\N	pset_01KT156V3XYYTVNR9BPWDBVWBZ	eur	{"value": "150", "precision": 20}	0	2026-06-01 10:36:05.888+02	2026-06-01 10:36:05.888+02	\N	\N	150	\N	\N	\N	\N
price_01KT156V3XXCQ8DQ6BX3D3BQ2F	\N	pset_01KT156V3XYYTVNR9BPWDBVWBZ	usd	{"value": "150", "precision": 20}	0	2026-06-01 10:36:05.888+02	2026-06-01 10:36:05.888+02	\N	\N	150	\N	\N	\N	\N
price_01KT156V3X8QSR77XY9P8JDG8W	\N	pset_01KT156V3XH2B3BKB2N0TPT7A6	eur	{"value": "150", "precision": 20}	0	2026-06-01 10:36:05.888+02	2026-06-01 10:36:05.888+02	\N	\N	150	\N	\N	\N	\N
price_01KT156V3XY96ZRKTX49BVHNM4	\N	pset_01KT156V3XH2B3BKB2N0TPT7A6	usd	{"value": "150", "precision": 20}	0	2026-06-01 10:36:05.888+02	2026-06-01 10:36:05.888+02	\N	\N	150	\N	\N	\N	\N
price_01KT156V3XXRJV3Q9Q8G3R28YZ	\N	pset_01KT156V3Y47SA55KHGT9M8VHH	eur	{"value": "150", "precision": 20}	0	2026-06-01 10:36:05.888+02	2026-06-01 10:36:05.888+02	\N	\N	150	\N	\N	\N	\N
price_01KT156V3Y9QJK9YPNRE5WQK2Z	\N	pset_01KT156V3Y47SA55KHGT9M8VHH	usd	{"value": "150", "precision": 20}	0	2026-06-01 10:36:05.888+02	2026-06-01 10:36:05.888+02	\N	\N	150	\N	\N	\N	\N
price_01KT156V3YWBNG50HMM96312Y9	\N	pset_01KT156V3YHWKTQ5Z5GZWS37Q1	eur	{"value": "150", "precision": 20}	0	2026-06-01 10:36:05.888+02	2026-06-01 10:36:05.888+02	\N	\N	150	\N	\N	\N	\N
price_01KT156V3YA3A1YXY9HSC1W6D2	\N	pset_01KT156V3YHWKTQ5Z5GZWS37Q1	usd	{"value": "150", "precision": 20}	0	2026-06-01 10:36:05.888+02	2026-06-01 10:36:05.888+02	\N	\N	150	\N	\N	\N	\N
price_01KSWK0MH4D9E6YCBCXAY82FYH	\N	pset_01KSWK0MH7VR7YCT2VPRBGFNF3	eur	{"value": "20", "precision": 20}	0	2026-05-30 16:01:10.439+02	2026-06-05 00:30:54.402+02	2026-06-05 00:30:54.393+02	\N	20	\N	\N	\N	\N
price_01KTAC4W68E80GY0CQQ30ZQXS6	\N	pset_01KTAC4W6AE91XR91GSTBWTHBY	usd	{"value": "1", "precision": 20}	0	2026-06-05 00:30:31.371+02	2026-06-05 00:35:51.972+02	2026-06-05 00:35:51.965+02	\N	1	\N	\N	\N	\N
price_01KTAC4W69QGPEC79V82XW06D9	\N	pset_01KTAC4W6AE91XR91GSTBWTHBY	usd	{"value": "1", "precision": 20}	1	2026-06-05 00:30:31.371+02	2026-06-05 00:35:51.972+02	2026-06-05 00:35:51.965+02	\N	1	\N	\N	\N	\N
price_01KSWNM2VW7D44VF138G9X2ZXP	\N	pset_01KSWK0MH7VR7YCT2VPRBGFNF3	usd	{"value": "100", "precision": 20}	1	2026-05-30 16:46:44.861+02	2026-06-05 00:30:54.402+02	2026-06-05 00:30:54.393+02	\N	100	\N	\N	\N	\N
price_01KSWK0MH584ZST4TQP3006QQG	\N	pset_01KSWK0MH7VR7YCT2VPRBGFNF3	usd	{"value": "1990", "precision": 20}	0	2026-05-30 16:01:10.44+02	2026-06-05 00:30:54.402+02	2026-06-05 00:30:54.393+02	\N	1990	\N	\N	\N	\N
price_01KTACAPYGCNYQZ8D8NG34ZGVZ	\N	pset_01KTACAPYHJ6PBPR81CB08Z82K	eur	{"value": "1", "precision": 20}	0	2026-06-05 00:33:42.61+02	2026-06-05 00:35:59.522+02	2026-06-05 00:35:59.515+02	\N	1	\N	\N	\N	\N
price_01KTACAPYGRMQXQYJQ8ZA2KGX3	\N	pset_01KTACAPYHJ6PBPR81CB08Z82K	usd	{"value": "1", "precision": 20}	0	2026-06-05 00:33:42.61+02	2026-06-05 00:35:59.522+02	2026-06-05 00:35:59.515+02	\N	1	\N	\N	\N	\N
price_01KTACAPYHDX71X2QN8B9CXFN5	\N	pset_01KTACAPYHJ6PBPR81CB08Z82K	usd	{"value": "1", "precision": 20}	1	2026-06-05 00:33:42.61+02	2026-06-05 00:35:59.522+02	2026-06-05 00:35:59.515+02	\N	1	\N	\N	\N	\N
price_01KTACDA0XMCZZ7R06ZM2434YE	\N	pset_01KTACDA0YWCM9QJKHQ58PWEK3	eur	{"value": "1", "precision": 20}	0	2026-06-05 00:35:07.679+02	2026-06-05 01:21:39.882+02	2026-06-05 01:21:39.873+02	\N	1	\N	\N	\N	\N
price_01KTACDA0XP29S115ZPK5T4AMS	\N	pset_01KTACDA0YWCM9QJKHQ58PWEK3	usd	{"value": "1", "precision": 20}	0	2026-06-05 00:35:07.679+02	2026-06-05 01:21:39.882+02	2026-06-05 01:21:39.873+02	\N	1	\N	\N	\N	\N
price_01KTACDA0YGJVTZGATTN61PBYV	\N	pset_01KTACDA0YWCM9QJKHQ58PWEK3	usd	{"value": "1", "precision": 20}	1	2026-06-05 00:35:07.679+02	2026-06-05 01:21:39.882+02	2026-06-05 01:21:39.873+02	\N	1	\N	\N	\N	\N
price_01KTAF58QAXT1VZF8G9T2AT5XJ	\N	pset_01KTAF58QBQAPD4Q3FSYKHBBD6	eur	{"value": "30", "precision": 20}	0	2026-06-05 01:23:09.931+02	2026-06-05 01:23:09.931+02	\N	\N	30	\N	\N	\N	\N
price_01KTAF58QBPA4GV51DCHM0GAET	\N	pset_01KTAF58QBQAPD4Q3FSYKHBBD6	usd	{"value": "30", "precision": 20}	0	2026-06-05 01:23:09.931+02	2026-06-05 01:23:09.931+02	\N	\N	30	\N	\N	\N	\N
price_01KTAF58QBNZ2M743GWCBH2VQR	\N	pset_01KTAF58QBQAPD4Q3FSYKHBBD6	usd	{"value": "30", "precision": 20}	1	2026-06-05 01:23:09.931+02	2026-06-05 01:23:09.931+02	\N	\N	30	\N	\N	\N	\N
price_01KTAFNNFEN5ZW7VJ86RSHKJWQ	\N	pset_01KTAFNNFF6EBWH2CQAKAKSRDK	eur	{"value": "10", "precision": 20}	0	2026-06-05 01:32:07.279+02	2026-06-05 01:32:07.279+02	\N	\N	10	\N	\N	\N	\N
price_01KTAFNNFEP494WVVJ664AKEN7	\N	pset_01KTAFNNFF6EBWH2CQAKAKSRDK	usd	{"value": "10", "precision": 20}	0	2026-06-05 01:32:07.279+02	2026-06-05 01:32:07.279+02	\N	\N	10	\N	\N	\N	\N
price_01KTAFNNFFQ2VCX3RME86E9GJJ	\N	pset_01KTAFNNFF6EBWH2CQAKAKSRDK	usd	{"value": "10", "precision": 20}	1	2026-06-05 01:32:07.279+02	2026-06-05 01:32:07.279+02	\N	\N	10	\N	\N	\N	\N
price_01KV5D7S9S2X9BDNKXFTDGQH81	\N	pset_01KV5D7S9TYTC7SFWVRVZEGQB0	eur	{"value": "300", "precision": 20}	0	2026-06-15 12:29:04.955+02	2026-06-15 12:29:04.955+02	\N	\N	300	\N	\N	\N	\N
price_01KV5D7S9SFRVHWEF3AT0VDXA2	\N	pset_01KV5D7S9TYTC7SFWVRVZEGQB0	usd	{"value": "300", "precision": 20}	0	2026-06-15 12:29:04.956+02	2026-06-15 12:29:04.956+02	\N	\N	300	\N	\N	\N	\N
price_01KV5D7S9T5SFD6NMNRFEYA2QM	\N	pset_01KV5D7S9TP10800TW3WHQ04C8	eur	{"value": "300", "precision": 20}	0	2026-06-15 12:29:04.956+02	2026-06-15 12:29:04.956+02	\N	\N	300	\N	\N	\N	\N
price_01KV5D7S9T7QRRM1C23AFWXNGP	\N	pset_01KV5D7S9TP10800TW3WHQ04C8	usd	{"value": "300", "precision": 20}	0	2026-06-15 12:29:04.956+02	2026-06-15 12:29:04.956+02	\N	\N	300	\N	\N	\N	\N
price_01KV5D7S9TXKREC6WGCXQEYZKE	\N	pset_01KV5D7S9TR19AN3QVC7ET7214	eur	{"value": "300", "precision": 20}	0	2026-06-15 12:29:04.956+02	2026-06-15 12:29:04.956+02	\N	\N	300	\N	\N	\N	\N
price_01KV5D7S9T8MPZXKNNZEJ23AKV	\N	pset_01KV5D7S9TR19AN3QVC7ET7214	usd	{"value": "300", "precision": 20}	0	2026-06-15 12:29:04.956+02	2026-06-15 12:29:04.956+02	\N	\N	300	\N	\N	\N	\N
price_01KV5DPWT3FC430E2C15FFQK9W	\N	pset_01KV5DPWT3ZY8C326065RTM590	eur	{"value": "10000", "precision": 20}	0	2026-06-15 12:37:20.067+02	2026-06-15 12:37:20.067+02	\N	\N	10000	\N	\N	\N	\N
price_01KV5E6041FSAQ0YXNA9NN3CGB	\N	pset_01KV5E6041R9MBH4H2CRAB8SQS	eur	{"value": "500", "precision": 20}	0	2026-06-15 12:45:34.978+02	2026-06-15 12:45:34.978+02	\N	\N	500	\N	\N	\N	\N
price_01KV5H8J3VT11Y9KE71E33ADTV	\N	pset_01KV5H8J3V85VMD43NPCT6A2WV	eur	{"value": "100", "precision": 20}	0	2026-06-15 13:39:24.668+02	2026-06-15 13:39:24.668+02	\N	\N	100	\N	\N	\N	\N
price_01KWTK7B8R4C4EFJRF200JQSEF	\N	pset_01KWT4YC2P3KA9BH80NS3SBC5K	usd	{"value": "1000000", "precision": 20}	0	2026-07-06 04:13:26.944+02	2026-07-06 04:22:16.281+02	2026-07-06 04:22:16.278+02	\N	1000000	1	20	{"value": "1", "precision": 20}	{"value": "20", "precision": 20}
price_01KWTK7B8SYMVH89ENX2E7VJMP	\N	pset_01KWT4YC2P3KA9BH80NS3SBC5K	eur	{"value": "1000000", "precision": 20}	0	2026-07-06 04:13:26.944+02	2026-07-06 04:22:16.281+02	2026-07-06 04:22:16.278+02	\N	1000000	1	20	{"value": "1", "precision": 20}	{"value": "20", "precision": 20}
price_01KWTKZBPN39E0MWSQ19W8964T	\N	pset_01KWTKZBPN656VNSKCY67QZ69K	bif	{"value": "1000000", "precision": 20}	0	2026-07-06 04:26:33.814+02	2026-07-06 04:26:33.814+02	\N	\N	1000000	\N	\N	\N	\N
price_01KWTKZBPNN7V6SQ2MM1TM3H50	\N	pset_01KWTKZBPN656VNSKCY67QZ69K	usd	{"value": "2020", "precision": 20}	0	2026-07-06 04:26:33.814+02	2026-07-06 04:26:33.814+02	\N	\N	2020	\N	\N	\N	\N
price_01KVAG33BF73JKWD2AQT768SYR	\N	pset_01KV5K1Y95KXR5B4TNKZGQAEM5	usd	{"value": "1900", "precision": 20}	0	2026-06-17 11:55:09.3+02	2026-06-17 11:55:09.3+02	\N	\N	1900	\N	\N	\N	\N
price_01KVAG33BFCHZGRSH8K503181G	\N	pset_01KV5K1Y95KXR5B4TNKZGQAEM5	eur	{"value": "1900", "precision": 20}	0	2026-06-17 11:55:09.3+02	2026-06-17 11:55:09.3+02	\N	\N	1900	\N	\N	\N	\N
price_01KVAG33BN6BWD43KV3V5DRCRD	\N	pset_01KV5K1Y956GPMCRPABP7AV8RY	usd	{"value": "1000", "precision": 20}	0	2026-06-17 11:55:09.304+02	2026-06-17 11:55:09.304+02	\N	\N	1000	\N	\N	\N	\N
price_01KVAG33BN1605V7ZHVWXJV32B	\N	pset_01KV5K1Y956GPMCRPABP7AV8RY	eur	{"value": "1000", "precision": 20}	0	2026-06-17 11:55:09.304+02	2026-06-17 11:55:09.304+02	\N	\N	1000	\N	\N	\N	\N
price_01KVAG33BP61SJQ5K6VR3D4R6F	\N	pset_01KV5K1Y9492N8RY3JNHW4BXC6	usd	{"value": "1000", "precision": 20}	0	2026-06-17 11:55:09.307+02	2026-06-17 11:55:09.307+02	\N	\N	1000	\N	\N	\N	\N
price_01KVAG33BPCQBEV3FA3MK45S4S	\N	pset_01KV5K1Y9492N8RY3JNHW4BXC6	eur	{"value": "1000", "precision": 20}	0	2026-06-17 11:55:09.307+02	2026-06-17 11:55:09.307+02	\N	\N	1000	\N	\N	\N	\N
price_01KWTK7B5ENSAFAG740N9C58DY	\N	pset_01KWT4YC2QP3SC4RFPX6CPF4DS	usd	{"value": "1000000", "precision": 20}	0	2026-07-06 04:13:26.844+02	2026-07-06 04:22:16.286+02	2026-07-06 04:22:16.278+02	\N	1000000	1	20	{"value": "1", "precision": 20}	{"value": "20", "precision": 20}
price_01KWTK7B5E96ZMZQ4D3WATFMYM	\N	pset_01KWT4YC2QP3SC4RFPX6CPF4DS	eur	{"value": "1000000", "precision": 20}	0	2026-07-06 04:13:26.844+02	2026-07-06 04:22:16.286+02	2026-07-06 04:22:16.278+02	\N	1000000	1	20	{"value": "1", "precision": 20}	{"value": "20", "precision": 20}
price_01KWTK7B83S6R59WXZ4YG47S8G	\N	pset_01KWT4YC2QGXJX6T5SWV243PAH	usd	{"value": "1030", "precision": 20}	0	2026-07-06 04:13:26.922+02	2026-07-06 04:22:16.29+02	2026-07-06 04:22:16.278+02	\N	1030	1	20	{"value": "1", "precision": 20}	{"value": "20", "precision": 20}
price_01KWTK7B83MYT8A0JNXYZKHC2H	\N	pset_01KWT4YC2QGXJX6T5SWV243PAH	eur	{"value": "1030", "precision": 20}	0	2026-07-06 04:13:26.922+02	2026-07-06 04:22:16.29+02	2026-07-06 04:22:16.278+02	\N	1030	1	20	{"value": "1", "precision": 20}	{"value": "20", "precision": 20}
price_01KVAM396GZNGAWG252X159JG4	\N	pset_01KV5DWPQ5KDEYENVPDVFDEHHR	usd	{"value": "2000", "precision": 20}	0	2026-06-17 13:05:09.589+02	2026-06-17 13:05:09.589+02	\N	\N	2000	\N	\N	\N	\N
price_01KVAM396HKCZE769HGG1YVDQX	\N	pset_01KV5DWPQ5KDEYENVPDVFDEHHR	eur	{"value": "2000", "precision": 20}	0	2026-06-17 13:05:09.589+02	2026-06-17 13:05:09.589+02	\N	\N	2000	\N	\N	\N	\N
price_01KVAN3BJPMDA2P1G3248A50XN	\N	pset_01KVAHVT45RD93ZFMXY8C2WFFX	usd	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.623+02	2026-06-17 13:22:40.623+02	\N	\N	200	1	20	{"value": "1", "precision": 20}	{"value": "20", "precision": 20}
price_01KVAN3BJPKFF66F5FFD6J1PRB	\N	pset_01KVAHVT45RD93ZFMXY8C2WFFX	eur	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.624+02	2026-06-17 13:22:40.624+02	\N	\N	200	1	20	{"value": "1", "precision": 20}	{"value": "20", "precision": 20}
price_01KVAN3BM20S1MYE0B2JNGSWJE	\N	pset_01KVAHVT497DGKT7D3S61C8042	usd	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.648+02	2026-06-17 13:22:40.648+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BM2EHV3NCFB4YBGS5SE	\N	pset_01KVAHVT497DGKT7D3S61C8042	eur	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.648+02	2026-06-17 13:22:40.648+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BMKNS4SQ12CNCKRPBGG	\N	pset_01KVAHVT4937W3EPX99YE0MSQT	usd	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.665+02	2026-06-17 13:22:40.665+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BMKFJBA7HBKG7EKCXQ6	\N	pset_01KVAHVT4937W3EPX99YE0MSQT	eur	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.666+02	2026-06-17 13:22:40.666+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BQ3Q4CQHHDQ82B9ZP8G	\N	pset_01KVAHVT49BNGM03CV3QQJFNPN	usd	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.751+02	2026-06-17 13:22:40.751+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BQ39ZYXCF9VXCEDC1DM	\N	pset_01KVAHVT49BNGM03CV3QQJFNPN	eur	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.751+02	2026-06-17 13:22:40.751+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BS0H16NYQ63H15K1V6Z	\N	pset_01KVAHVT488QNH6K8DWXBVK5N4	usd	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.805+02	2026-06-17 13:22:40.805+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BS06D1JNAVB9PTV5JBF	\N	pset_01KVAHVT488QNH6K8DWXBVK5N4	eur	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.805+02	2026-06-17 13:22:40.805+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BSH68EE735ZS81NE2W5	\N	pset_01KVAHVT486V8XNKGAXQF1GTH1	usd	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.825+02	2026-06-17 13:22:40.825+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BSHHSX4P0N93K4RHRJ4	\N	pset_01KVAHVT486V8XNKGAXQF1GTH1	eur	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.825+02	2026-06-17 13:22:40.825+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BV3HN30V11ZT3EPSM4P	\N	pset_01KVAHVT4747ADVFQ1E0HFE763	usd	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.873+02	2026-06-17 13:22:40.873+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BV3YG6XWCJ828NC0PC3	\N	pset_01KVAHVT4747ADVFQ1E0HFE763	eur	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.874+02	2026-06-17 13:22:40.874+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BX4R7KT6WWXHRQ9XEE4	\N	pset_01KVAHVT47M0QVSR1EVWHEW1MM	usd	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.941+02	2026-06-17 13:22:40.941+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BX4CYFEV8JHB060CG1E	\N	pset_01KVAHVT47M0QVSR1EVWHEW1MM	eur	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.941+02	2026-06-17 13:22:40.941+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BYC70WSJNGZ1G11WPBC	\N	pset_01KVAHVT4726BH46J4SDJ20KKA	usd	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.978+02	2026-06-17 13:22:40.978+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BYCFWWVEFXHC0PVW12J	\N	pset_01KVAHVT4726BH46J4SDJ20KKA	eur	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.978+02	2026-06-17 13:22:40.978+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3C25CZA17W474S631NFE	\N	pset_01KVAHVT46FY9ZRB1CV6JZAF1Y	usd	{"value": "200", "precision": 20}	0	2026-06-17 13:22:41.101+02	2026-06-17 13:22:41.101+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3C25EFBNM4E777TB1K81	\N	pset_01KVAHVT46FY9ZRB1CV6JZAF1Y	eur	{"value": "200", "precision": 20}	0	2026-06-17 13:22:41.102+02	2026-06-17 13:22:41.102+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3C2ZTG8XN5A2JHKE1HCZ	\N	pset_01KVAHVT4608T1016E8V0EY3M1	usd	{"value": "200", "precision": 20}	0	2026-06-17 13:22:41.137+02	2026-06-17 13:22:41.137+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3C30TYD40GQ0P8FNG8EZ	\N	pset_01KVAHVT4608T1016E8V0EY3M1	eur	{"value": "200", "precision": 20}	0	2026-06-17 13:22:41.137+02	2026-06-17 13:22:41.137+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3C4WQEPS8HJNMSG6MN8Z	\N	pset_01KVAHVT4ATEHMPJ0904F0MY23	usd	{"value": "200", "precision": 20}	0	2026-06-17 13:22:41.192+02	2026-06-17 13:22:41.192+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3C4W2N5E4DV4C0PR0HCH	\N	pset_01KVAHVT4ATEHMPJ0904F0MY23	eur	{"value": "200", "precision": 20}	0	2026-06-17 13:22:41.192+02	2026-06-17 13:22:41.192+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3C5PJ6BK9GKZQB6DJE2A	\N	pset_01KVAHVT4AQ1X70YK8PESJ5EMG	usd	{"value": "200", "precision": 20}	0	2026-06-17 13:22:41.21+02	2026-06-17 13:22:41.21+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3C5P3JD9T9ZPKRWZZKCX	\N	pset_01KVAHVT4AQ1X70YK8PESJ5EMG	eur	{"value": "200", "precision": 20}	0	2026-06-17 13:22:41.21+02	2026-06-17 13:22:41.21+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BMHPWVS9M541A8EKF01	\N	pset_01KVAHVT4A57TBKSHPF9JYNKG6	usd	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.669+02	2026-06-17 13:22:40.669+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BMHJG1VYXBPW7EESA71	\N	pset_01KVAHVT4A57TBKSHPF9JYNKG6	eur	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.669+02	2026-06-17 13:22:40.669+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BN1SFW1YBCT8B3D54EZ	\N	pset_01KVAHVT49SHP034ZQ3Y63V10X	usd	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.686+02	2026-06-17 13:22:40.686+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BN14HQMR7T7SJNS39GQ	\N	pset_01KVAHVT49SHP034ZQ3Y63V10X	eur	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.686+02	2026-06-17 13:22:40.686+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BR5MS16BJMA0V6JFP2A	\N	pset_01KVAHVT48AT7Q7M9K2563NZ1R	usd	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.778+02	2026-06-17 13:22:40.778+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BR5X9YCRM5F43F281SB	\N	pset_01KVAHVT48AT7Q7M9K2563NZ1R	eur	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.778+02	2026-06-17 13:22:40.778+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BR7M7YTBM78THJ46AFF	\N	pset_01KVAHVT48DT5PNG1Q87K5BZ25	usd	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.78+02	2026-06-17 13:22:40.78+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BR7XX2E2J99YMGW9NT6	\N	pset_01KVAHVT48DT5PNG1Q87K5BZ25	eur	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.78+02	2026-06-17 13:22:40.78+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BVG69KFCD0QR1VYKQA3	\N	pset_01KVAHVT47X01EWBZWJVY3C7MZ	usd	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.893+02	2026-06-17 13:22:40.893+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BVGC4G2YXFGF9CR4JNV	\N	pset_01KVAHVT47X01EWBZWJVY3C7MZ	eur	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.893+02	2026-06-17 13:22:40.893+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BXVJDHBNSJZWRP37XBX	\N	pset_01KVAHVT47ABW1HSCBQYDP833B	usd	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.974+02	2026-06-17 13:22:40.974+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3BXV5EYK9PPS8XQY2JXX	\N	pset_01KVAHVT47ABW1HSCBQYDP833B	eur	{"value": "200", "precision": 20}	0	2026-06-17 13:22:40.974+02	2026-06-17 13:22:40.974+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3C18SVT5KXMFMNKK224B	\N	pset_01KVAHVT46AVPYKBJCAB32Q2ZT	usd	{"value": "200", "precision": 20}	0	2026-06-17 13:22:41.078+02	2026-06-17 13:22:41.078+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3C18BZSQ517YWS2K1SZ2	\N	pset_01KVAHVT46AVPYKBJCAB32Q2ZT	eur	{"value": "200", "precision": 20}	0	2026-06-17 13:22:41.078+02	2026-06-17 13:22:41.078+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3C4CX99D40X1NV1NGWZ4	\N	pset_01KVAHVT46VN53S8BNKGM7QZBC	usd	{"value": "200", "precision": 20}	0	2026-06-17 13:22:41.17+02	2026-06-17 13:22:41.17+02	\N	\N	200	\N	\N	\N	\N
price_01KVAN3C4CKN515D3NHX373W4W	\N	pset_01KVAHVT46VN53S8BNKGM7QZBC	eur	{"value": "200", "precision": 20}	0	2026-06-17 13:22:41.17+02	2026-06-17 13:22:41.17+02	\N	\N	200	\N	\N	\N	\N
price_01KWTK7B92HAZ0HY97406YP8V3	\N	pset_01KWT4YC2R9PPR5X1FZW7GRVJ4	usd	{"value": "1000000", "precision": 20}	0	2026-07-06 04:13:26.952+02	2026-07-06 04:22:16.296+02	2026-07-06 04:22:16.278+02	\N	1000000	1	20	{"value": "1", "precision": 20}	{"value": "20", "precision": 20}
price_01KWTK7B92PN8MJYFMPJ754MPK	\N	pset_01KWT4YC2R9PPR5X1FZW7GRVJ4	eur	{"value": "1000000", "precision": 20}	0	2026-07-06 04:13:26.952+02	2026-07-06 04:22:16.296+02	2026-07-06 04:22:16.278+02	\N	1000000	1	20	{"value": "1", "precision": 20}	{"value": "20", "precision": 20}
price_01KWTK7B7S15NFGPP9PHA3ASKQ	\N	pset_01KWT4YC2R1NJT7B46YXPZ3Y7B	usd	{"value": "1030", "precision": 20}	0	2026-07-06 04:13:26.916+02	2026-07-06 04:22:16.3+02	2026-07-06 04:22:16.278+02	\N	1030	1	20	{"value": "1", "precision": 20}	{"value": "20", "precision": 20}
price_01KWTK7B7SAKA82YX1K4BCTWRD	\N	pset_01KWT4YC2R1NJT7B46YXPZ3Y7B	eur	{"value": "1030", "precision": 20}	0	2026-07-06 04:13:26.916+02	2026-07-06 04:22:16.3+02	2026-07-06 04:22:16.278+02	\N	1030	1	20	{"value": "1", "precision": 20}	{"value": "20", "precision": 20}
\.


--
-- Data for Name: price_list; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.price_list (id, status, starts_at, ends_at, rules_count, title, description, type, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: price_list_rule; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.price_list_rule (id, price_list_id, created_at, updated_at, deleted_at, value, attribute) FROM stdin;
\.


--
-- Data for Name: price_preference; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.price_preference (id, attribute, value, is_tax_inclusive, created_at, updated_at, deleted_at) FROM stdin;
prpref_01KSCR9E5MEDG3F2MKA1K2DBNQ	currency_code	usd	f	2026-05-24 12:25:30.805+02	2026-05-24 12:25:30.805+02	\N
prpref_01KSCR9E6AE2GM6DZ1DE377XVA	region_id	reg_01KSCR9E5TH7739ZGVPZHV9YR7	f	2026-05-24 12:25:30.827+02	2026-05-24 12:25:30.827+02	\N
prpref_01KSR0QAQV5GNP1XRAK4YAAC1B	region_id	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	f	2026-05-28 21:24:33.404+02	2026-05-28 21:24:33.404+02	\N
prpref_01KSCR9E49C3X2ZCWPA09DNWVB	currency_code	eur	f	2026-05-24 12:25:30.761+02	2026-06-17 15:36:50.696+02	\N
prpref_01KWSK8XHQDM2GV17HYEA8EBYE	currency_code	bif	f	2026-07-05 18:55:03.992+02	2026-07-05 18:55:03.992+02	\N
\.


--
-- Data for Name: price_rule; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.price_rule (id, value, priority, price_id, created_at, updated_at, deleted_at, attribute, operator) FROM stdin;
prule_01KSCR9E8S9W8AVPN64Z19VRK3	reg_01KSCR9E5TH7739ZGVPZHV9YR7	0	price_01KSCR9E8SJXGFJJZ82RTKQG73	2026-05-24 12:25:30.905+02	2026-05-30 15:30:55.274+02	2026-05-30 15:30:55.252+02	region_id	eq
prule_01KSCR9E8SNARMN7T7R1XDX010	reg_01KSCR9E5TH7739ZGVPZHV9YR7	0	price_01KSCR9E8S2CNZ5YA3C1F5CGB7	2026-05-24 12:25:30.906+02	2026-05-30 15:30:55.292+02	2026-05-30 15:30:55.252+02	region_id	eq
prule_01KSWNM2VWSV1WS4DHSKAKEX1K	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	0	price_01KSWNM2VW7D44VF138G9X2ZXP	2026-05-30 16:46:44.862+02	2026-06-05 00:30:54.413+02	2026-06-05 00:30:54.393+02	region_id	eq
prule_01KTAC4W69B1TDJ5FC5T8G1XAH	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	0	price_01KTAC4W69QGPEC79V82XW06D9	2026-06-05 00:30:31.371+02	2026-06-05 00:35:51.979+02	2026-06-05 00:35:51.965+02	region_id	eq
prule_01KTACAPYHFP4K9HFT1VATKTE5	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	0	price_01KTACAPYHDX71X2QN8B9CXFN5	2026-06-05 00:33:42.61+02	2026-06-05 00:35:59.529+02	2026-06-05 00:35:59.515+02	region_id	eq
prule_01KTACDA0YZ1434BRS6HFRYRCN	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	0	price_01KTACDA0YGJVTZGATTN61PBYV	2026-06-05 00:35:07.679+02	2026-06-05 01:21:39.895+02	2026-06-05 01:21:39.873+02	region_id	eq
prule_01KTAF58QB11ACR1GTAYVZTJNH	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	0	price_01KTAF58QBNZ2M743GWCBH2VQR	2026-06-05 01:23:09.931+02	2026-06-05 01:23:09.931+02	\N	region_id	eq
prule_01KTAFNNFFS65XCJG6ZS2Z6SCA	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	0	price_01KTAFNNFFQ2VCX3RME86E9GJJ	2026-06-05 01:32:07.279+02	2026-06-05 01:32:07.279+02	\N	region_id	eq
\.


--
-- Data for Name: price_set; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.price_set (id, created_at, updated_at, deleted_at) FROM stdin;
pset_01KSCR9ECHE40GY2K2Z5RKJPRB	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N
pset_01KSCR9ECHJZD63PJ02VHCNE2C	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N
pset_01KSCR9ECHAE8KQBHZ663MV2PJ	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N
pset_01KSCR9ECHXG21SJRGHCHR5G6W	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N
pset_01KSCR9ECH59RXB1EYQD7C92QR	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N
pset_01KSCR9ECH0WA5W8B6HBTATXXS	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N
pset_01KSCR9ECHG3AQVY3E7N1JYSPK	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N
pset_01KSCR9ECJD3F4M0ATYW79596N	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N
pset_01KSCR9ECJ24G1ANC2YGZ4T2VP	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N
pset_01KSCR9ECJD177T8XAPQWQFPYA	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N
pset_01KSCR9ECJ1YF8H2NHK8JST4SC	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N
pset_01KSCR9ECJXJ0V6RMB5B6DY6CQ	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N
pset_01KSCR9ECJNKJHQ3GEK4BKBWTV	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N
pset_01KSCR9ECJ1GZ29MKTKB6Y4N8P	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N
pset_01KSCR9ECJ0JGFPNPMPC6NG8N2	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N
pset_01KSCR9ECJ1RY8AB7QRXEEHW56	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N
pset_01KSCR9ECJEZEHBK43XZZQ5VSW	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N
pset_01KSCR9ECKQ26RMJM2G8KSW22X	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N
pset_01KSCR9ECKWY6XV6NFT0PXZHS3	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N
pset_01KSCR9ECKT191MKK8JV695GZM	2026-05-24 12:25:31.027+02	2026-05-24 12:25:31.027+02	\N
pset_01KSDEEB5GG42PTYFK4AVTZ6R1	2026-05-24 18:52:40.241+02	2026-05-24 18:52:40.241+02	\N
pset_01KSDEEB5HM8D6TN7EBYJHBRZ4	2026-05-24 18:52:40.241+02	2026-05-24 18:52:40.241+02	\N
pset_01KSH2A90QGA5K2VSPJ7S60MDE	2026-05-26 04:37:41.783+02	2026-05-26 04:37:41.783+02	\N
pset_01KSCR9E8SESZKQR1E3J6NBEQ4	2026-05-24 12:25:30.905+02	2026-05-30 15:30:55.252+02	2026-05-30 15:30:55.252+02
pset_01KSCR9E8SQ6D9GFMMRAVSVXWW	2026-05-24 12:25:30.905+02	2026-05-30 15:30:55.275+02	2026-05-30 15:30:55.252+02
pset_01KT156V3VBFXRVV4Q11J8X3XT	2026-06-01 10:36:05.887+02	2026-06-01 10:36:05.887+02	\N
pset_01KT156V3VSWX8PMXA8DKS19M8	2026-06-01 10:36:05.887+02	2026-06-01 10:36:05.887+02	\N
pset_01KT156V3VMAZHWFFK682434N8	2026-06-01 10:36:05.887+02	2026-06-01 10:36:05.887+02	\N
pset_01KT156V3WNZEM2ZPB9FZXE16S	2026-06-01 10:36:05.887+02	2026-06-01 10:36:05.887+02	\N
pset_01KT156V3WTFAP7TW72AJS9F1E	2026-06-01 10:36:05.887+02	2026-06-01 10:36:05.887+02	\N
pset_01KT156V3WN800MMRWMSF4T0P4	2026-06-01 10:36:05.887+02	2026-06-01 10:36:05.887+02	\N
pset_01KT156V3W3NDDMBH6632Q7VTP	2026-06-01 10:36:05.887+02	2026-06-01 10:36:05.887+02	\N
pset_01KT156V3X95FXBAB3JK6R7ABP	2026-06-01 10:36:05.887+02	2026-06-01 10:36:05.887+02	\N
pset_01KT156V3XYYTVNR9BPWDBVWBZ	2026-06-01 10:36:05.887+02	2026-06-01 10:36:05.887+02	\N
pset_01KT156V3XH2B3BKB2N0TPT7A6	2026-06-01 10:36:05.887+02	2026-06-01 10:36:05.887+02	\N
pset_01KT156V3Y47SA55KHGT9M8VHH	2026-06-01 10:36:05.887+02	2026-06-01 10:36:05.887+02	\N
pset_01KT156V3YHWKTQ5Z5GZWS37Q1	2026-06-01 10:36:05.887+02	2026-06-01 10:36:05.887+02	\N
pset_01KSWJDGAHMXYPTTQECENVHTV8	2026-05-30 15:50:43.538+02	2026-06-04 16:02:08.989+02	2026-06-04 16:02:08.988+02
pset_01KSWJKRZDQT4ANWVMWG7DH9C6	2026-05-30 15:54:09.005+02	2026-06-04 16:02:26.949+02	2026-06-04 16:02:26.948+02
pset_01KSWK0MH7VR7YCT2VPRBGFNF3	2026-05-30 16:01:10.439+02	2026-06-05 00:30:54.394+02	2026-06-05 00:30:54.393+02
pset_01KT9F4RHCQPK7AMGXDXC9VYSZ	2026-06-04 16:03:38.925+02	2026-06-05 00:32:47.353+02	2026-06-05 00:32:47.353+02
pset_01KTAC4W6AE91XR91GSTBWTHBY	2026-06-05 00:30:31.37+02	2026-06-05 00:35:51.966+02	2026-06-05 00:35:51.965+02
pset_01KTACAPYHJ6PBPR81CB08Z82K	2026-06-05 00:33:42.609+02	2026-06-05 00:35:59.516+02	2026-06-05 00:35:59.515+02
pset_01KTACDA0YWCM9QJKHQ58PWEK3	2026-06-05 00:35:07.678+02	2026-06-05 01:21:39.874+02	2026-06-05 01:21:39.873+02
pset_01KTAF58QBQAPD4Q3FSYKHBBD6	2026-06-05 01:23:09.931+02	2026-06-05 01:23:09.931+02	\N
pset_01KTAFNNFF6EBWH2CQAKAKSRDK	2026-06-05 01:32:07.279+02	2026-06-05 01:32:07.279+02	\N
pset_01KTJ4E45RW880A8MYSVFTT8DD	2026-06-08 00:49:41.304+02	2026-06-08 00:52:07.317+02	2026-06-08 00:52:07.316+02
pset_01KTJ4K798SP2PAF6PCAAXKW87	2026-06-08 00:52:28.328+02	2026-06-08 01:10:45.844+02	2026-06-08 01:10:45.844+02
pset_01KV5D7S9TYTC7SFWVRVZEGQB0	2026-06-15 12:29:04.955+02	2026-06-15 12:29:04.955+02	\N
pset_01KV5D7S9TP10800TW3WHQ04C8	2026-06-15 12:29:04.955+02	2026-06-15 12:29:04.955+02	\N
pset_01KV5D7S9TR19AN3QVC7ET7214	2026-06-15 12:29:04.955+02	2026-06-15 12:29:04.955+02	\N
pset_01KV5DPWT3ZY8C326065RTM590	2026-06-15 12:37:20.067+02	2026-06-15 12:37:20.067+02	\N
pset_01KV5DWPQ5KDEYENVPDVFDEHHR	2026-06-15 12:40:30.438+02	2026-06-15 12:40:30.438+02	\N
pset_01KV5E6041R9MBH4H2CRAB8SQS	2026-06-15 12:45:34.978+02	2026-06-15 12:45:34.978+02	\N
pset_01KV5H8J3V85VMD43NPCT6A2WV	2026-06-15 13:39:24.668+02	2026-06-15 13:39:24.668+02	\N
pset_01KV5K1Y9492N8RY3JNHW4BXC6	2026-06-15 14:10:44.902+02	2026-06-15 14:10:44.902+02	\N
pset_01KV5K1Y956GPMCRPABP7AV8RY	2026-06-15 14:10:44.902+02	2026-06-15 14:10:44.902+02	\N
pset_01KV5K1Y95KXR5B4TNKZGQAEM5	2026-06-15 14:10:44.902+02	2026-06-15 14:10:44.902+02	\N
pset_01KVAHVT45RD93ZFMXY8C2WFFX	2026-06-17 12:26:07.627+02	2026-06-17 12:26:07.627+02	\N
pset_01KVAHVT46VN53S8BNKGM7QZBC	2026-06-17 12:26:07.627+02	2026-06-17 12:26:07.627+02	\N
pset_01KVAHVT4608T1016E8V0EY3M1	2026-06-17 12:26:07.627+02	2026-06-17 12:26:07.627+02	\N
pset_01KVAHVT46FY9ZRB1CV6JZAF1Y	2026-06-17 12:26:07.627+02	2026-06-17 12:26:07.627+02	\N
pset_01KVAHVT46AVPYKBJCAB32Q2ZT	2026-06-17 12:26:07.627+02	2026-06-17 12:26:07.627+02	\N
pset_01KVAHVT47ABW1HSCBQYDP833B	2026-06-17 12:26:07.627+02	2026-06-17 12:26:07.627+02	\N
pset_01KVAHVT47M0QVSR1EVWHEW1MM	2026-06-17 12:26:07.627+02	2026-06-17 12:26:07.627+02	\N
pset_01KVAHVT4726BH46J4SDJ20KKA	2026-06-17 12:26:07.627+02	2026-06-17 12:26:07.627+02	\N
pset_01KVAHVT47X01EWBZWJVY3C7MZ	2026-06-17 12:26:07.627+02	2026-06-17 12:26:07.627+02	\N
pset_01KVAHVT4747ADVFQ1E0HFE763	2026-06-17 12:26:07.627+02	2026-06-17 12:26:07.627+02	\N
pset_01KVAHVT486V8XNKGAXQF1GTH1	2026-06-17 12:26:07.627+02	2026-06-17 12:26:07.627+02	\N
pset_01KVAHVT48DT5PNG1Q87K5BZ25	2026-06-17 12:26:07.627+02	2026-06-17 12:26:07.627+02	\N
pset_01KVAHVT488QNH6K8DWXBVK5N4	2026-06-17 12:26:07.627+02	2026-06-17 12:26:07.627+02	\N
pset_01KVAHVT48AT7Q7M9K2563NZ1R	2026-06-17 12:26:07.627+02	2026-06-17 12:26:07.627+02	\N
pset_01KVAHVT49BNGM03CV3QQJFNPN	2026-06-17 12:26:07.627+02	2026-06-17 12:26:07.627+02	\N
pset_01KVAHVT4937W3EPX99YE0MSQT	2026-06-17 12:26:07.627+02	2026-06-17 12:26:07.627+02	\N
pset_01KVAHVT49SHP034ZQ3Y63V10X	2026-06-17 12:26:07.627+02	2026-06-17 12:26:07.627+02	\N
pset_01KVAHVT497DGKT7D3S61C8042	2026-06-17 12:26:07.627+02	2026-06-17 12:26:07.627+02	\N
pset_01KVAHVT4A57TBKSHPF9JYNKG6	2026-06-17 12:26:07.627+02	2026-06-17 12:26:07.627+02	\N
pset_01KVAHVT4AQ1X70YK8PESJ5EMG	2026-06-17 12:26:07.627+02	2026-06-17 12:26:07.627+02	\N
pset_01KVAHVT4ATEHMPJ0904F0MY23	2026-06-17 12:26:07.627+02	2026-06-17 12:26:07.627+02	\N
pset_01KVANBJ09PZRD5ZM52KW8DW8J	2026-06-17 13:27:09.321+02	2026-06-17 13:27:09.321+02	\N
pset_01KWT4YC2P3KA9BH80NS3SBC5K	2026-07-06 00:03:52.793+02	2026-07-06 04:22:16.278+02	2026-07-06 04:22:16.278+02
pset_01KWT4YC2QP3SC4RFPX6CPF4DS	2026-07-06 00:03:52.793+02	2026-07-06 04:22:16.284+02	2026-07-06 04:22:16.278+02
pset_01KWT4YC2QGXJX6T5SWV243PAH	2026-07-06 00:03:52.794+02	2026-07-06 04:22:16.288+02	2026-07-06 04:22:16.278+02
pset_01KWT4YC2R9PPR5X1FZW7GRVJ4	2026-07-06 00:03:52.794+02	2026-07-06 04:22:16.293+02	2026-07-06 04:22:16.278+02
pset_01KWT4YC2R1NJT7B46YXPZ3Y7B	2026-07-06 00:03:52.794+02	2026-07-06 04:22:16.299+02	2026-07-06 04:22:16.278+02
pset_01KWTKZBPN5HPVGKXTQXEEG2Q3	2026-07-06 04:26:33.813+02	2026-07-06 04:26:33.813+02	\N
pset_01KWTKZBPNPY6S1ZFFZK6NXSTR	2026-07-06 04:26:33.813+02	2026-07-06 04:26:33.813+02	\N
pset_01KWTKZBPN656VNSKCY67QZ69K	2026-07-06 04:26:33.813+02	2026-07-06 04:26:33.813+02	\N
\.


--
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product (id, title, handle, subtitle, description, is_giftcard, status, thumbnail, weight, length, height, width, origin_country, hs_code, mid_code, material, collection_id, type_id, discountable, external_id, created_at, updated_at, deleted_at, metadata) FROM stdin;
prod_01KSCR9EA8QJ19M3XNSJCQTBKP	Medusa T-Shirt	t-shirt	\N	Reimagine the feeling of a classic T-shirt. With our cotton T-shirts, everyday essentials no longer have to be ordinary.	f	published	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-front.png	400	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-24 12:25:30.956+02	2026-05-24 12:25:30.956+02	\N	\N
prod_01KSCR9EA893MYMWYSTYVN97YD	Medusa Sweatshirt	sweatshirt	\N	Reimagine the feeling of a classic sweatshirt. With our cotton sweatshirt, everyday essentials no longer have to be ordinary.	f	published	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatshirt-vintage-front.png	400	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-24 12:25:30.956+02	2026-05-24 12:25:30.956+02	\N	\N
prod_01KSCR9EA81H268P4TP8HZKH76	Medusa Sweatpants	sweatpants	\N	Reimagine the feeling of classic sweatpants. With our cotton sweatpants, everyday essentials no longer have to be ordinary.	f	published	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatpants-gray-front.png	400	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N	\N
prod_01KSCR9EA8NPXFPM0RR3W38Q5X	Medusa Shorts	shorts	\N	Reimagine the feeling of classic shorts. With our cotton shorts, everyday essentials no longer have to be ordinary.	f	published	https://medusa-public-images.s3.eu-west-1.amazonaws.com/shorts-vintage-front.png	400	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N	\N
prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	ma-saani	\N	Hello	f	published	http://localhost:9000/static/1779641482219-image.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-24 18:52:40.192+02	2026-05-24 18:52:40.192+02	\N	\N
prod_01KSH2A8YPQ2M4AN368YBJ9X3C	Sufuria	sufuria	\N	\N	f	published	http://localhost:9000/static/1779763040657-image.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-26 04:37:41.72+02	2026-05-26 04:37:41.72+02	\N	\N
prod_01KT156V00QYP2NS7HYG4BWMYG	Mapapa	mapapa	\N	\N	f	published	http://localhost:9000/static/1780302709862-image.jpg	2.5	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-06-01 10:36:05.762+02	2026-06-01 10:36:05.762+02	\N	\N
prod_01KTJ4E43N2WV9BNRB99A9XMED	Test	test			f	published	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-06-08 00:49:41.24+02	2026-06-08 00:52:07.281+02	2026-06-08 00:52:07.278+02	\N
prod_01KTJ4K77CRV73SNDHAGTJSC32	test	test			f	published	https://minio.afyaclick.bi/eastmarket/icon-01KTJ4K51VVNM74F64H1PF37EA.png	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-06-08 00:52:28.272+02	2026-06-08 01:10:45.81+02	2026-06-08 01:10:45.808+02	\N
prod_01KV5D7S5A3GT3TNV6JJ36QA88	Sandale	sandale	\N	\N	f	published	https://s3.eastmarket.africa/eastmarket/image-01KV5D13J6R2NW8G1966SMY1G3.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-06-15 12:29:04.814+02	2026-06-15 12:29:04.814+02	\N	\N
prod_01KV5DPWQMJ87E724G2PHS05ZZ	Veste	veste	\N	\N	f	published	https://s3.eastmarket.africa/eastmarket/image-01KV5DMAN6NY8VEXS535R9A7H6.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-06-15 12:37:19.992+02	2026-06-15 12:37:19.992+02	\N	\N
prod_01KV5DWPN1992BC1RARAP2H0K1	Matelas	matelas	\N	\N	f	published	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-06-15 12:40:30.37+02	2026-06-15 12:40:30.37+02	\N	\N
prod_01KV5H8J0X1ZXZA46EZ0MG683D	Moustiquaire	moustiquaire	\N	\N	f	published	https://s3.eastmarket.africa/eastmarket/image-01KV5H6NG3D61DR9K4T2Y5MA7C.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-06-15 13:39:24.577+02	2026-06-15 13:39:24.577+02	\N	\N
prod_01KV5K1Y66BRSD3K4GDMN4M1YS	Gg	gg	\N	\N	f	published	https://s3.eastmarket.africa/eastmarket/image-01KV5JR733EB6YJ4A4G4TNYWNN.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-06-15 14:10:44.807+02	2026-06-15 14:10:44.807+02	\N	\N
prod_01KV5E601185BKG901X7QG2CEW	Parfum	parfum	\N		f	published	https://s3.eastmarket.africa/eastmarket/image-01KV5E4GMW45D7C631PSDBJWB2.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-06-15 12:45:34.884+02	2026-06-15 14:51:28.199+02	\N	\N
prod_01KVAHVT1115P37Z781SCQWX1W	Sandales plates pour femmes  (Modèles assortis)	sandales-plates-pour-femmes-modeles-assortis	\N	Sandales plates confortables pour femmes, disponibles en plusieurs modèles et coloris élégants (marron, beige, noir, bordeaux). Idéales pour le quotidien.	f	published	https://s3.eastmarket.africa/eastmarket/image-01KVAGYGR5HSSKB5HN5VY7MM8M.jpg	\N	\N	\N	\N	\N	\N	\N	Simili-cuir / Synthétique (ou Cuir si c'est le cas)	\N	\N	t	\N	2026-06-17 12:26:07.523+02	2026-06-17 12:26:07.523+02	\N	\N
prod_01KVANBHYVPHYHTH3VKVZDF1VJ	Sandales Compensées pour Femme à Motifs Dorés et Strass	sandales-compensees-pour-femme-a-motifs-dores-et-strass	\N	Ajoutez une touche d'élégance et de confort à votre quotidien avec ces magnifiques sandales compensées pour femme. Parfaites pour l'été ou pour vos sorties décontractées, elles s'associent facilement avec toutes vos tenues.\nDesign élégant : Brides ornées de superbes détails brodés dorés et de strass brillants.\nConfort optimal : Semelle compensée légère offrant un excellent amorti et un maintien agréable toute la journée.\nStyles variés : Disponibles en plusieurs motifs et coloris (voir photos) pour s'adapter à toutes vos envies.	f	published	https://s3.eastmarket.africa/eastmarket/image-01KVAN6DH62MSTWWS69F7JRS3N.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-06-17 13:27:09.277+02	2026-06-17 13:27:09.277+02	\N	\N
prod_01KWT4YBXAFKGSHX0R820VDJS4	Soulier de qualité.	soulier-de-qualite	\N	\N	f	published	https://s3.eastmarket.africa/eastmarket/image-01KWT4FXDQ78MMRJQZR3G7FVA4.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-07-06 00:03:52.622+02	2026-07-06 04:22:16.259+02	2026-07-06 04:22:16.259+02	\N
prod_01KWTKZBN13GNZVP6YNBMAD3VP	Soulier de bonne qualité	soulier-de-bonne-qualite	\N	\N	f	published	https://s3.eastmarket.africa/eastmarket/image-01KWTKVV2H2M65YENN1QQ6EMKH.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-07-06 04:26:33.763+02	2026-07-06 04:26:33.763+02	\N	\N
\.


--
-- Data for Name: product_category; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_category (id, name, description, handle, mpath, is_active, is_internal, rank, parent_category_id, created_at, updated_at, deleted_at, metadata) FROM stdin;
pcat_01KSCR9E9ZVXTPG1E8VDG33A00	Shirts		shirts	pcat_01KSCR9E9ZVXTPG1E8VDG33A00	t	f	0	\N	2026-05-24 12:25:30.944+02	2026-05-24 12:25:30.944+02	\N	\N
pcat_01KSCR9EA00PCV8J1G7TVW9RZZ	Sweatshirts		sweatshirts	pcat_01KSCR9EA00PCV8J1G7TVW9RZZ	t	f	1	\N	2026-05-24 12:25:30.944+02	2026-05-24 12:25:30.944+02	\N	\N
pcat_01KSCR9EA08Z6GF51A4AFAJZHD	Pants		pants	pcat_01KSCR9EA08Z6GF51A4AFAJZHD	t	f	2	\N	2026-05-24 12:25:30.944+02	2026-05-24 12:25:30.944+02	\N	\N
pcat_01KSCR9EA04Q9Y9507EGNTRQXD	Merch		merch	pcat_01KSCR9EA04Q9Y9507EGNTRQXD	t	f	3	\N	2026-05-24 12:25:30.944+02	2026-05-24 12:25:30.944+02	\N	\N
pcat_01KT14GCRSDYWE182SD6AFW2BB	Soulier		soulier	pcat_01KT14GCRSDYWE182SD6AFW2BB	t	f	4	\N	2026-06-01 10:23:50.297+02	2026-06-01 10:23:50.297+02	\N	\N
\.


--
-- Data for Name: product_category_product; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_category_product (product_id, product_category_id) FROM stdin;
prod_01KSCR9EA8QJ19M3XNSJCQTBKP	pcat_01KSCR9E9ZVXTPG1E8VDG33A00
prod_01KSCR9EA893MYMWYSTYVN97YD	pcat_01KSCR9EA00PCV8J1G7TVW9RZZ
prod_01KSCR9EA81H268P4TP8HZKH76	pcat_01KSCR9EA08Z6GF51A4AFAJZHD
prod_01KSCR9EA8NPXFPM0RR3W38Q5X	pcat_01KSCR9EA04Q9Y9507EGNTRQXD
prod_01KV5D7S5A3GT3TNV6JJ36QA88	pcat_01KT14GCRSDYWE182SD6AFW2BB
prod_01KV5DPWQMJ87E724G2PHS05ZZ	pcat_01KSCR9E9ZVXTPG1E8VDG33A00
prod_01KV5H8J0X1ZXZA46EZ0MG683D	pcat_01KSCR9EA08Z6GF51A4AFAJZHD
prod_01KV5E601185BKG901X7QG2CEW	pcat_01KSCR9EA04Q9Y9507EGNTRQXD
prod_01KVAHVT1115P37Z781SCQWX1W	pcat_01KT14GCRSDYWE182SD6AFW2BB
\.


--
-- Data for Name: product_collection; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_collection (id, title, handle, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: product_option; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_option (id, title, product_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
opt_01KSCR9EAAMZZG57WJ63YN293Y	Size	prod_01KSCR9EA8QJ19M3XNSJCQTBKP	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N
opt_01KSCR9EAADB7WXZ5XBNW8XDZ4	Color	prod_01KSCR9EA8QJ19M3XNSJCQTBKP	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N
opt_01KSCR9EABXDRZECP334J8BX8Y	Size	prod_01KSCR9EA893MYMWYSTYVN97YD	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N
opt_01KSCR9EABVXPPW21WA0VR0HBS	Size	prod_01KSCR9EA81H268P4TP8HZKH76	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N
opt_01KSCR9EAC9EKPN95NCJ2Y7XXH	Size	prod_01KSCR9EA8NPXFPM0RR3W38Q5X	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N
opt_01KSDEEB3Z9ZD5PSCVWM1NFTGY	Couleur	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	\N	2026-05-24 18:52:40.192+02	2026-05-24 18:52:40.192+02	\N
opt_01KSH2A8YRND19YSYHKYCYJCB6	Default option	prod_01KSH2A8YPQ2M4AN368YBJ9X3C	\N	2026-05-26 04:37:41.721+02	2026-05-26 04:37:41.721+02	\N
opt_01KT156V00QGSY6PCW57HZ7JB7	Taille	prod_01KT156V00QYP2NS7HYG4BWMYG	\N	2026-06-01 10:36:05.763+02	2026-06-01 10:36:05.763+02	\N
opt_01KT156V01KJ1ZX7RVJQVV431H	Tailles	prod_01KT156V00QYP2NS7HYG4BWMYG	\N	2026-06-01 10:36:05.763+02	2026-06-01 10:36:05.763+02	\N
opt_01KTJ4E43QHV31JVM8K5ERW6YX	Default option	prod_01KTJ4E43N2WV9BNRB99A9XMED	\N	2026-06-08 00:49:41.24+02	2026-06-08 00:52:07.306+02	2026-06-08 00:52:07.278+02
opt_01KTJ4K77EFS31JZBTZ65HC1KM	Default option	prod_01KTJ4K77CRV73SNDHAGTJSC32	\N	2026-06-08 00:52:28.272+02	2026-06-08 01:10:45.827+02	2026-06-08 01:10:45.808+02
opt_01KV5D7S5CCMKJ8B5RAXKJZ44P	Couleur	prod_01KV5D7S5A3GT3TNV6JJ36QA88	\N	2026-06-15 12:29:04.814+02	2026-06-15 12:29:04.814+02	\N
opt_01KV5DPWQNGAQD0EDZV7563S4F	Default option	prod_01KV5DPWQMJ87E724G2PHS05ZZ	\N	2026-06-15 12:37:19.994+02	2026-06-15 12:37:19.994+02	\N
opt_01KV5DWPN1KAPXB3C9YS9R0XVA	Default option	prod_01KV5DWPN1992BC1RARAP2H0K1	\N	2026-06-15 12:40:30.37+02	2026-06-15 12:40:30.37+02	\N
opt_01KV5E6012RBV53TRSYYWH5THV	Default option	prod_01KV5E601185BKG901X7QG2CEW	\N	2026-06-15 12:45:34.884+02	2026-06-15 12:45:34.884+02	\N
opt_01KV5H8J0YBGQDFNQKSPCYG6JD	Default option	prod_01KV5H8J0X1ZXZA46EZ0MG683D	\N	2026-06-15 13:39:24.577+02	2026-06-15 13:39:24.577+02	\N
opt_01KV5K1Y674ADKHFWTJ33BJ8Y4	Couleur	prod_01KV5K1Y66BRSD3K4GDMN4M1YS	\N	2026-06-15 14:10:44.809+02	2026-06-15 14:10:44.809+02	\N
opt_01KVAHVT129M3M7N4FE3BAM57S	Taille	prod_01KVAHVT1115P37Z781SCQWX1W	\N	2026-06-17 12:26:07.524+02	2026-06-17 12:26:07.524+02	\N
opt_01KVAHVT12XAK7BBF1ECYTWD4R	Couleur	prod_01KVAHVT1115P37Z781SCQWX1W	\N	2026-06-17 12:26:07.524+02	2026-06-17 12:26:07.524+02	\N
opt_01KVANBHYWGYT1JX7HSBX112PE	Default option	prod_01KVANBHYVPHYHTH3VKVZDF1VJ	\N	2026-06-17 13:27:09.277+02	2026-06-17 13:27:09.277+02	\N
opt_01KWT4YBXCPRR6M3B4VZ54VNE1	Taille	prod_01KWT4YBXAFKGSHX0R820VDJS4	\N	2026-07-06 00:03:52.622+02	2026-07-06 04:22:16.266+02	2026-07-06 04:22:16.259+02
opt_01KWTKZBN25WHNG91Z4V36GT58	Taille	prod_01KWTKZBN13GNZVP6YNBMAD3VP	\N	2026-07-06 04:26:33.763+02	2026-07-06 04:26:33.763+02	\N
\.


--
-- Data for Name: product_option_value; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_option_value (id, value, option_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
optval_01KSCR9EAAPK0DPVZZV7061DD3	S	opt_01KSCR9EAAMZZG57WJ63YN293Y	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N
optval_01KSCR9EAAA6SZKS2ADX58ETH3	M	opt_01KSCR9EAAMZZG57WJ63YN293Y	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N
optval_01KSCR9EAAXMECRFD50M4VZBK5	L	opt_01KSCR9EAAMZZG57WJ63YN293Y	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N
optval_01KSCR9EAATZB8J567B1H5ZYGN	XL	opt_01KSCR9EAAMZZG57WJ63YN293Y	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N
optval_01KSCR9EAAY43F9VW0PYAKVVDY	Black	opt_01KSCR9EAADB7WXZ5XBNW8XDZ4	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N
optval_01KSCR9EAAWS50R4TEENNCTFAS	White	opt_01KSCR9EAADB7WXZ5XBNW8XDZ4	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N
optval_01KSCR9EABBJ0ZMZNVEPWTF0KA	S	opt_01KSCR9EABXDRZECP334J8BX8Y	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N
optval_01KSCR9EABJTFJXVY9FBVBVM72	M	opt_01KSCR9EABXDRZECP334J8BX8Y	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N
optval_01KSCR9EABFHXT4GRVC6ZR7F02	L	opt_01KSCR9EABXDRZECP334J8BX8Y	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N
optval_01KSCR9EAB3JHYAGPA96BS0C5G	XL	opt_01KSCR9EABXDRZECP334J8BX8Y	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N
optval_01KSCR9EAB0C7E9QMMHGSZN1G9	S	opt_01KSCR9EABVXPPW21WA0VR0HBS	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N
optval_01KSCR9EABZEG2HF1QAWNSK5PC	M	opt_01KSCR9EABVXPPW21WA0VR0HBS	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N
optval_01KSCR9EABRHB3DHD62JRXM3K0	L	opt_01KSCR9EABVXPPW21WA0VR0HBS	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N
optval_01KSCR9EABGQ4GH89MQMET732Z	XL	opt_01KSCR9EABVXPPW21WA0VR0HBS	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N
optval_01KSCR9EACHJWB3TAV05R5VWBJ	S	opt_01KSCR9EAC9EKPN95NCJ2Y7XXH	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N
optval_01KSCR9EAC5VGGMXNZCFEXRZJA	M	opt_01KSCR9EAC9EKPN95NCJ2Y7XXH	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N
optval_01KSCR9EACVC08S2V3ZWHG363Y	L	opt_01KSCR9EAC9EKPN95NCJ2Y7XXH	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N
optval_01KSCR9EACZ94YZWJD13MWH763	XL	opt_01KSCR9EAC9EKPN95NCJ2Y7XXH	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N
optval_01KSDEEB3ZSF95TTX0KBVP1JZX	Rouge	opt_01KSDEEB3Z9ZD5PSCVWM1NFTGY	\N	2026-05-24 18:52:40.192+02	2026-05-24 18:52:40.192+02	\N
optval_01KSDEEB3ZWTVTJ6HZDNAXV560	noir	opt_01KSDEEB3Z9ZD5PSCVWM1NFTGY	\N	2026-05-24 18:52:40.192+02	2026-05-24 18:52:40.192+02	\N
optval_01KSH2A8YQP63W3VS4MN0QDV67	Default option value	opt_01KSH2A8YRND19YSYHKYCYJCB6	\N	2026-05-26 04:37:41.721+02	2026-05-26 04:37:41.721+02	\N
optval_01KT156V00PJGMP7FTP4V3D740	Noir	opt_01KT156V00QGSY6PCW57HZ7JB7	\N	2026-06-01 10:36:05.763+02	2026-06-01 10:36:05.763+02	\N
optval_01KT156V00ECWD6RR95E6FNR4C	Blue	opt_01KT156V00QGSY6PCW57HZ7JB7	\N	2026-06-01 10:36:05.763+02	2026-06-01 10:36:05.763+02	\N
optval_01KT156V00V76KZAMB33A8GGAX	vert	opt_01KT156V00QGSY6PCW57HZ7JB7	\N	2026-06-01 10:36:05.763+02	2026-06-01 10:36:05.763+02	\N
optval_01KT156V01SKS0VC1DFFQ624AG	39	opt_01KT156V01KJ1ZX7RVJQVV431H	\N	2026-06-01 10:36:05.763+02	2026-06-01 10:36:05.763+02	\N
optval_01KT156V01XJKV1HPDJRCR35G4	37	opt_01KT156V01KJ1ZX7RVJQVV431H	\N	2026-06-01 10:36:05.763+02	2026-06-01 10:36:05.763+02	\N
optval_01KT156V01MFKQMDE01AX72KN2	36	opt_01KT156V01KJ1ZX7RVJQVV431H	\N	2026-06-01 10:36:05.763+02	2026-06-01 10:36:05.763+02	\N
optval_01KT156V01D8KG0168DC8FR8PP	35	opt_01KT156V01KJ1ZX7RVJQVV431H	\N	2026-06-01 10:36:05.763+02	2026-06-01 10:36:05.763+02	\N
optval_01KTJ4E43QDHAJYWVAM2E66T4C	Default option value	opt_01KTJ4E43QHV31JVM8K5ERW6YX	\N	2026-06-08 00:49:41.24+02	2026-06-08 00:52:07.321+02	2026-06-08 00:52:07.278+02
optval_01KTJ4K77E9GY2DTQ73B6ES0YB	Default option value	opt_01KTJ4K77EFS31JZBTZ65HC1KM	\N	2026-06-08 00:52:28.272+02	2026-06-08 01:10:45.846+02	2026-06-08 01:10:45.808+02
optval_01KV5D7S5BT57VWT9GRZEGZKSA	Rouge	opt_01KV5D7S5CCMKJ8B5RAXKJZ44P	\N	2026-06-15 12:29:04.815+02	2026-06-15 12:29:04.815+02	\N
optval_01KV5D7S5BBDDJ2XAQDCKR8GX4	Vert	opt_01KV5D7S5CCMKJ8B5RAXKJZ44P	\N	2026-06-15 12:29:04.815+02	2026-06-15 12:29:04.815+02	\N
optval_01KV5D7S5BAEE8Q4KQV2TNC92P	Noire	opt_01KV5D7S5CCMKJ8B5RAXKJZ44P	\N	2026-06-15 12:29:04.815+02	2026-06-15 12:29:04.815+02	\N
optval_01KV5DPWQNW0RRH5J81S249ZRR	Default option value	opt_01KV5DPWQNGAQD0EDZV7563S4F	\N	2026-06-15 12:37:19.994+02	2026-06-15 12:37:19.994+02	\N
optval_01KV5DWPN1N2XTY6EN59AJSJFH	Default option value	opt_01KV5DWPN1KAPXB3C9YS9R0XVA	\N	2026-06-15 12:40:30.37+02	2026-06-15 12:40:30.37+02	\N
optval_01KV5E60120YAVQB0FEW8QHTGN	Default option value	opt_01KV5E6012RBV53TRSYYWH5THV	\N	2026-06-15 12:45:34.884+02	2026-06-15 12:45:34.884+02	\N
optval_01KV5H8J0Y0FY0VEP8DVM7M98H	Default option value	opt_01KV5H8J0YBGQDFNQKSPCYG6JD	\N	2026-06-15 13:39:24.577+02	2026-06-15 13:39:24.577+02	\N
optval_01KV5K1Y66376RNGFACBCFA06Y	Rouge	opt_01KV5K1Y674ADKHFWTJ33BJ8Y4	\N	2026-06-15 14:10:44.809+02	2026-06-15 14:10:44.809+02	\N
optval_01KV5K1Y66GW1H3Z93692JW9WE	Vert	opt_01KV5K1Y674ADKHFWTJ33BJ8Y4	\N	2026-06-15 14:10:44.809+02	2026-06-15 14:10:44.809+02	\N
optval_01KV5K1Y6629FDYX15Q2EPXV4N	Noire	opt_01KV5K1Y674ADKHFWTJ33BJ8Y4	\N	2026-06-15 14:10:44.809+02	2026-06-15 14:10:44.809+02	\N
optval_01KVAHVT11RXBH5WDYED6VV177	36	opt_01KVAHVT129M3M7N4FE3BAM57S	\N	2026-06-17 12:26:07.524+02	2026-06-17 12:26:07.524+02	\N
optval_01KVAHVT113HKKX10XWDDXHQY9	37	opt_01KVAHVT129M3M7N4FE3BAM57S	\N	2026-06-17 12:26:07.524+02	2026-06-17 12:26:07.524+02	\N
optval_01KVAHVT119RKE73QNR93H0C2F	38	opt_01KVAHVT129M3M7N4FE3BAM57S	\N	2026-06-17 12:26:07.524+02	2026-06-17 12:26:07.524+02	\N
optval_01KVAHVT118HCSPH384FYSWFYN	39	opt_01KVAHVT129M3M7N4FE3BAM57S	\N	2026-06-17 12:26:07.524+02	2026-06-17 12:26:07.524+02	\N
optval_01KVAHVT12VDJ4E81NHX627XAA	40	opt_01KVAHVT129M3M7N4FE3BAM57S	\N	2026-06-17 12:26:07.524+02	2026-06-17 12:26:07.524+02	\N
optval_01KVAHVT12F4VGWVYCN744WFAX	41	opt_01KVAHVT129M3M7N4FE3BAM57S	\N	2026-06-17 12:26:07.524+02	2026-06-17 12:26:07.524+02	\N
optval_01KVAHVT127ATD5WJ24A61MH31	42	opt_01KVAHVT129M3M7N4FE3BAM57S	\N	2026-06-17 12:26:07.524+02	2026-06-17 12:26:07.524+02	\N
optval_01KVAHVT12XKJ2VAKQ68WWKBR9	Rouge	opt_01KVAHVT12XAK7BBF1ECYTWD4R	\N	2026-06-17 12:26:07.524+02	2026-06-17 12:26:07.524+02	\N
optval_01KVAHVT12NGPP5EGPRA63N9ZP	Noir	opt_01KVAHVT12XAK7BBF1ECYTWD4R	\N	2026-06-17 12:26:07.524+02	2026-06-17 12:26:07.524+02	\N
optval_01KVAHVT12QMENVMP1JGGV61PJ	Rose	opt_01KVAHVT12XAK7BBF1ECYTWD4R	\N	2026-06-17 12:26:07.524+02	2026-06-17 12:26:07.524+02	\N
optval_01KVANBHYW8Y2QHGCQDQWNTSK6	Default option value	opt_01KVANBHYWGYT1JX7HSBX112PE	\N	2026-06-17 13:27:09.277+02	2026-06-17 13:27:09.277+02	\N
optval_01KWT4YBXBP310M3DEBHDRMY6B	36	opt_01KWT4YBXCPRR6M3B4VZ54VNE1	\N	2026-07-06 00:03:52.622+02	2026-07-06 04:22:16.273+02	2026-07-06 04:22:16.259+02
optval_01KWT4YBXB2FXQWEZ5J38MVTRJ	37	opt_01KWT4YBXCPRR6M3B4VZ54VNE1	\N	2026-07-06 00:03:52.622+02	2026-07-06 04:22:16.273+02	2026-07-06 04:22:16.259+02
optval_01KWT4YBXBBTVB51Q7VXFXBQN5	38	opt_01KWT4YBXCPRR6M3B4VZ54VNE1	\N	2026-07-06 00:03:52.622+02	2026-07-06 04:22:16.273+02	2026-07-06 04:22:16.259+02
optval_01KWT4YBXCA22NR1AJWM5VNQWZ	39	opt_01KWT4YBXCPRR6M3B4VZ54VNE1	\N	2026-07-06 00:03:52.622+02	2026-07-06 04:22:16.273+02	2026-07-06 04:22:16.259+02
optval_01KWT4YBXCQZ4J99VWNNVBY551	40	opt_01KWT4YBXCPRR6M3B4VZ54VNE1	\N	2026-07-06 00:03:52.622+02	2026-07-06 04:22:16.273+02	2026-07-06 04:22:16.259+02
optval_01KWTKZBN121HFGWM46W8D7Z5H	36	opt_01KWTKZBN25WHNG91Z4V36GT58	\N	2026-07-06 04:26:33.763+02	2026-07-06 04:26:33.763+02	\N
optval_01KWTKZBN1BC2NN74PS7H2VSHQ	37	opt_01KWTKZBN25WHNG91Z4V36GT58	\N	2026-07-06 04:26:33.763+02	2026-07-06 04:26:33.763+02	\N
optval_01KWTKZBN1AT0TXECSGGFRNZNH	38	opt_01KWTKZBN25WHNG91Z4V36GT58	\N	2026-07-06 04:26:33.763+02	2026-07-06 04:26:33.763+02	\N
\.


--
-- Data for Name: product_sales_channel; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_sales_channel (product_id, sales_channel_id, id, created_at, updated_at, deleted_at) FROM stdin;
prod_01KSCR9EA8QJ19M3XNSJCQTBKP	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KSCR9EAR02GTFZ02KWZ9QCJR	2026-05-24 12:25:30.967909+02	2026-05-24 12:25:30.967909+02	\N
prod_01KSCR9EA893MYMWYSTYVN97YD	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KSCR9EAR8KH3MQNXB4VKJKDJ	2026-05-24 12:25:30.967909+02	2026-05-24 12:25:30.967909+02	\N
prod_01KSCR9EA81H268P4TP8HZKH76	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KSCR9EAR1ARFZ79S0J2X7HFQ	2026-05-24 12:25:30.967909+02	2026-05-24 12:25:30.967909+02	\N
prod_01KSCR9EA8NPXFPM0RR3W38Q5X	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KSCR9EARMF1V15GEBDW9D173	2026-05-24 12:25:30.967909+02	2026-05-24 12:25:30.967909+02	\N
prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KSDEEB4CJ7WRJ8BMGXQHTRGX	2026-05-24 18:52:40.203459+02	2026-05-24 18:52:40.203459+02	\N
prod_01KSH2A8YPQ2M4AN368YBJ9X3C	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KSH2A8Z43T31YE7277VD8515	2026-05-26 04:37:41.732177+02	2026-05-26 04:37:41.732177+02	\N
prod_01KT156V00QYP2NS7HYG4BWMYG	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KT156V0MRQNVC94NED1EF665	2026-06-01 10:36:05.777638+02	2026-06-01 10:36:05.777638+02	\N
prod_01KTJ4E43N2WV9BNRB99A9XMED	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KTJ4E44BGKDNTXTYTNPMJ290	2026-06-08 00:49:41.258258+02	2026-06-08 00:52:07.289+02	2026-06-08 00:52:07.288+02
prod_01KTJ4K77CRV73SNDHAGTJSC32	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KTJ4K77ZG1MWFKXBFF6HV3FY	2026-06-08 00:52:28.287152+02	2026-06-08 01:10:45.816+02	2026-06-08 01:10:45.816+02
prod_01KV5D7S5A3GT3TNV6JJ36QA88	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KV5D7S6APBBJD5P97BAG3ES8	2026-06-15 12:29:04.841479+02	2026-06-15 12:29:04.841479+02	\N
prod_01KV5DPWQMJ87E724G2PHS05ZZ	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KV5DPWRDZYQBES4QCMG0444T	2026-06-15 12:37:20.013304+02	2026-06-15 12:37:20.013304+02	\N
prod_01KV5DWPN1992BC1RARAP2H0K1	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KV5DWPNJBF5BYDVQ4XKS666J	2026-06-15 12:40:30.386123+02	2026-06-15 12:40:30.386123+02	\N
prod_01KV5E601185BKG901X7QG2CEW	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KV5E601PWDMG9BGNENAZBN0Y	2026-06-15 12:45:34.902008+02	2026-06-15 12:45:34.902008+02	\N
prod_01KV5H8J0X1ZXZA46EZ0MG683D	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KV5H8J1QM943R6E69AWFGQ35	2026-06-15 13:39:24.598542+02	2026-06-15 13:39:24.598542+02	\N
prod_01KV5K1Y66BRSD3K4GDMN4M1YS	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KV5K1Y72EMN0EP54K9XR5BV4	2026-06-15 14:10:44.832562+02	2026-06-15 14:10:44.832562+02	\N
prod_01KVAHVT1115P37Z781SCQWX1W	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KVAHVT1KRP0TQWVXJ5MH75NQ	2026-06-17 12:26:07.538409+02	2026-06-17 12:26:07.538409+02	\N
prod_01KVANBHYVPHYHTH3VKVZDF1VJ	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KVANBHZ7T3GBSY5MRHZMW180	2026-06-17 13:27:09.287664+02	2026-06-17 13:27:09.287664+02	\N
prod_01KWT4YBXAFKGSHX0R820VDJS4	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KWT4YBY93R322HX64M3Y64AA	2026-07-06 00:03:52.648767+02	2026-07-06 04:22:16.27+02	2026-07-06 04:22:16.27+02
prod_01KWTKZBN13GNZVP6YNBMAD3VP	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KWTKZBNDGW4F1K00B3NTY418	2026-07-06 04:26:33.773437+02	2026-07-06 04:26:33.773437+02	\N
\.


--
-- Data for Name: product_shipping_profile; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_shipping_profile (product_id, shipping_profile_id, id, created_at, updated_at, deleted_at) FROM stdin;
prod_01KSCR9EA8QJ19M3XNSJCQTBKP	sp_01KSCR9E7ATTZKDD71J1GAA2V8	prodsp_01KSCR9EAYT0VCPRCQK2J2GSK8	2026-05-24 12:25:30.974151+02	2026-05-24 12:25:30.974151+02	\N
prod_01KSCR9EA893MYMWYSTYVN97YD	sp_01KSCR9E7ATTZKDD71J1GAA2V8	prodsp_01KSCR9EAYHGXZ7WVRZ49EKWQN	2026-05-24 12:25:30.974151+02	2026-05-24 12:25:30.974151+02	\N
prod_01KSCR9EA81H268P4TP8HZKH76	sp_01KSCR9E7ATTZKDD71J1GAA2V8	prodsp_01KSCR9EAYCRT1754GN62BTN0H	2026-05-24 12:25:30.974151+02	2026-05-24 12:25:30.974151+02	\N
prod_01KSCR9EA8NPXFPM0RR3W38Q5X	sp_01KSCR9E7ATTZKDD71J1GAA2V8	prodsp_01KSCR9EAYTVNBFJGB6C954791	2026-05-24 12:25:30.974151+02	2026-05-24 12:25:30.974151+02	\N
prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	sp_01KSCR51Y68N200HV70RYQZGR2	prodsp_01KSDEEB4K7Q1F1Y1BG1SMY6NS	2026-05-24 18:52:40.211351+02	2026-05-24 18:52:40.211351+02	\N
prod_01KSH2A8YPQ2M4AN368YBJ9X3C	sp_01KSCR51Y68N200HV70RYQZGR2	prodsp_01KSH2A8ZJYCVPH6P5Q3J4T3ZS	2026-05-26 04:37:41.746458+02	2026-05-26 04:37:41.746458+02	\N
prod_01KT156V00QYP2NS7HYG4BWMYG	sp_01KSCR51Y68N200HV70RYQZGR2	prodsp_01KT156V11XBSMVW9HBNCS31P6	2026-06-01 10:36:05.793333+02	2026-06-01 10:36:05.793333+02	\N
prod_01KV5D7S5A3GT3TNV6JJ36QA88	sp_01KSCR51Y68N200HV70RYQZGR2	prodsp_01KV5D7S6V9WAJP2A28QP20JGK	2026-06-15 12:29:04.85897+02	2026-06-15 12:29:04.85897+02	\N
prod_01KV5DPWQMJ87E724G2PHS05ZZ	sp_01KSCR51Y68N200HV70RYQZGR2	prodsp_01KV5DPWRS0TAT4A5M10445B3Y	2026-06-15 12:37:20.024351+02	2026-06-15 12:37:20.024351+02	\N
prod_01KV5DWPN1992BC1RARAP2H0K1	sp_01KSCR51Y68N200HV70RYQZGR2	prodsp_01KV5DWPNSPFHKTQ8CT446ACAS	2026-06-15 12:40:30.393298+02	2026-06-15 12:40:30.393298+02	\N
prod_01KV5E601185BKG901X7QG2CEW	sp_01KSCR51Y68N200HV70RYQZGR2	prodsp_01KV5E6021B3K4JY2YR9QY2VR7	2026-06-15 12:45:34.913415+02	2026-06-15 12:45:34.913415+02	\N
prod_01KV5H8J0X1ZXZA46EZ0MG683D	sp_01KSCR51Y68N200HV70RYQZGR2	prodsp_01KV5H8J23QJ99N8DVVK4STAZR	2026-06-15 13:39:24.611188+02	2026-06-15 13:39:24.611188+02	\N
prod_01KV5K1Y66BRSD3K4GDMN4M1YS	sp_01KSCR51Y68N200HV70RYQZGR2	prodsp_01KV5K1Y79B4WT3D3E9QWFAMQR	2026-06-15 14:10:44.841318+02	2026-06-15 14:10:44.841318+02	\N
prod_01KVAHVT1115P37Z781SCQWX1W	sp_01KSCR51Y68N200HV70RYQZGR2	prodsp_01KVAHVT1WAV2P1W08C4KNNBRZ	2026-06-17 12:26:07.548395+02	2026-06-17 12:26:07.548395+02	\N
prod_01KVANBHYVPHYHTH3VKVZDF1VJ	sp_01KSCR51Y68N200HV70RYQZGR2	prodsp_01KVANBHZG6JHBNA7ZW7QE89AM	2026-06-17 13:27:09.295228+02	2026-06-17 13:27:09.295228+02	\N
prod_01KWT4YBXAFKGSHX0R820VDJS4	sp_01KSCR51Y68N200HV70RYQZGR2	prodsp_01KWT4YBYYK4V3P4A435KHM7RM	2026-07-06 00:03:52.670075+02	2026-07-06 04:22:16.277+02	2026-07-06 04:22:16.276+02
prod_01KWTKZBN13GNZVP6YNBMAD3VP	sp_01KSCR51Y68N200HV70RYQZGR2	prodsp_01KWTKZBNPXRC5ECMBVXRHBKFV	2026-07-06 04:26:33.781855+02	2026-07-06 04:26:33.781855+02	\N
\.


--
-- Data for Name: product_tag; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_tag (id, value, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: product_tags; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_tags (product_id, product_tag_id) FROM stdin;
\.


--
-- Data for Name: product_type; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_type (id, value, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: product_variant; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_variant (id, title, sku, barcode, ean, upc, allow_backorder, manage_inventory, hs_code, origin_country, mid_code, material, weight, length, height, width, metadata, variant_rank, product_id, created_at, updated_at, deleted_at, thumbnail) FROM stdin;
variant_01KSCR9EBB5SDB79TPFJJ35HPP	S / Black	SHIRT-S-BLACK	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KSCR9EA8QJ19M3XNSJCQTBKP	2026-05-24 12:25:30.989+02	2026-05-24 12:25:30.989+02	\N	\N
variant_01KSCR9EBCY91XPNSCP8NXT8F2	S / White	SHIRT-S-WHITE	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KSCR9EA8QJ19M3XNSJCQTBKP	2026-05-24 12:25:30.989+02	2026-05-24 12:25:30.989+02	\N	\N
variant_01KSCR9EBC52MBRCSV877TQXP5	M / Black	SHIRT-M-BLACK	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KSCR9EA8QJ19M3XNSJCQTBKP	2026-05-24 12:25:30.989+02	2026-05-24 12:25:30.989+02	\N	\N
variant_01KSCR9EBC5YZVT1MZ87Z9R80B	M / White	SHIRT-M-WHITE	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KSCR9EA8QJ19M3XNSJCQTBKP	2026-05-24 12:25:30.989+02	2026-05-24 12:25:30.989+02	\N	\N
variant_01KSCR9EBCRNX20J9HW4HNEJ8H	L / Black	SHIRT-L-BLACK	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KSCR9EA8QJ19M3XNSJCQTBKP	2026-05-24 12:25:30.989+02	2026-05-24 12:25:30.989+02	\N	\N
variant_01KSCR9EBCTFGSPR2Y2E5TN1FE	L / White	SHIRT-L-WHITE	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KSCR9EA8QJ19M3XNSJCQTBKP	2026-05-24 12:25:30.989+02	2026-05-24 12:25:30.989+02	\N	\N
variant_01KSCR9EBC5APY2TXMQGMBGJJR	XL / Black	SHIRT-XL-BLACK	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KSCR9EA8QJ19M3XNSJCQTBKP	2026-05-24 12:25:30.989+02	2026-05-24 12:25:30.989+02	\N	\N
variant_01KSCR9EBCN34947HRNE0YX51J	XL / White	SHIRT-XL-WHITE	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KSCR9EA8QJ19M3XNSJCQTBKP	2026-05-24 12:25:30.989+02	2026-05-24 12:25:30.989+02	\N	\N
variant_01KSCR9EBCE6BWGPAF65WMKV0A	S	SWEATSHIRT-S	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KSCR9EA893MYMWYSTYVN97YD	2026-05-24 12:25:30.989+02	2026-05-24 12:25:30.989+02	\N	\N
variant_01KSCR9EBCNMMZ5Y3Q1Y4JDWPF	M	SWEATSHIRT-M	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KSCR9EA893MYMWYSTYVN97YD	2026-05-24 12:25:30.989+02	2026-05-24 12:25:30.989+02	\N	\N
variant_01KSCR9EBCXS1X5N5HFAWFFBF4	L	SWEATSHIRT-L	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KSCR9EA893MYMWYSTYVN97YD	2026-05-24 12:25:30.989+02	2026-05-24 12:25:30.989+02	\N	\N
variant_01KSCR9EBCMJZVF6QQHWN7X7WQ	XL	SWEATSHIRT-XL	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KSCR9EA893MYMWYSTYVN97YD	2026-05-24 12:25:30.989+02	2026-05-24 12:25:30.989+02	\N	\N
variant_01KSCR9EBC6H04N5PNKAG5YYAA	S	SWEATPANTS-S	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KSCR9EA81H268P4TP8HZKH76	2026-05-24 12:25:30.989+02	2026-05-24 12:25:30.989+02	\N	\N
variant_01KSCR9EBCYVV229KF5B1DHB0P	M	SWEATPANTS-M	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KSCR9EA81H268P4TP8HZKH76	2026-05-24 12:25:30.989+02	2026-05-24 12:25:30.989+02	\N	\N
variant_01KSCR9EBCPQ162CT8P8JYJ208	L	SWEATPANTS-L	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KSCR9EA81H268P4TP8HZKH76	2026-05-24 12:25:30.989+02	2026-05-24 12:25:30.989+02	\N	\N
variant_01KSCR9EBC6292NXWNKFT12BMR	XL	SWEATPANTS-XL	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KSCR9EA81H268P4TP8HZKH76	2026-05-24 12:25:30.989+02	2026-05-24 12:25:30.989+02	\N	\N
variant_01KSCR9EBD5ARPWGHVT9C1YYH2	S	SHORTS-S	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KSCR9EA8NPXFPM0RR3W38Q5X	2026-05-24 12:25:30.989+02	2026-05-24 12:25:30.989+02	\N	\N
variant_01KSCR9EBD48FCYXEHZ28PQTG1	M	SHORTS-M	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KSCR9EA8NPXFPM0RR3W38Q5X	2026-05-24 12:25:30.989+02	2026-05-24 12:25:30.989+02	\N	\N
variant_01KSCR9EBDR67KBGB0BSV76Z1Q	L	SHORTS-L	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KSCR9EA8NPXFPM0RR3W38Q5X	2026-05-24 12:25:30.989+02	2026-05-24 12:25:30.989+02	\N	\N
variant_01KSCR9EBDQEQRFWFY9KZ76VHQ	XL	SHORTS-XL	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KSCR9EA8NPXFPM0RR3W38Q5X	2026-05-24 12:25:30.989+02	2026-05-24 12:25:30.989+02	\N	\N
variant_01KSDEEB4X5XQS5EZAMWG8KH96	Rouge	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	2026-05-24 18:52:40.222+02	2026-05-24 18:52:40.222+02	\N	\N
variant_01KSDEEB4Y5FRC1M9K6A8SS7E4	noir	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	2026-05-24 18:52:40.222+02	2026-05-24 18:52:40.222+02	\N	\N
variant_01KSH2A902V793W1CP9H7Y6ZMT	Default variant	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KSH2A8YPQ2M4AN368YBJ9X3C	2026-05-26 04:37:41.763+02	2026-05-26 04:37:41.763+02	\N	\N
variant_01KT156V1Q6CDQTENG754WVA87	Noir / 39	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KT156V00QYP2NS7HYG4BWMYG	2026-06-01 10:36:05.817+02	2026-06-01 10:36:05.817+02	\N	\N
variant_01KT156V1QEBNZXXPH2KM55161	Noir / 37	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	prod_01KT156V00QYP2NS7HYG4BWMYG	2026-06-01 10:36:05.818+02	2026-06-01 10:36:05.818+02	\N	\N
variant_01KT156V1QZZFWVV6M8QH9QATX	Noir / 36	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	prod_01KT156V00QYP2NS7HYG4BWMYG	2026-06-01 10:36:05.818+02	2026-06-01 10:36:05.818+02	\N	\N
variant_01KT156V1RSWV24EF942MK1XM1	Noir / 35	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	prod_01KT156V00QYP2NS7HYG4BWMYG	2026-06-01 10:36:05.818+02	2026-06-01 10:36:05.818+02	\N	\N
variant_01KT156V1RDGKYWHTKBZ5AEPKA	Blue / 39	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	prod_01KT156V00QYP2NS7HYG4BWMYG	2026-06-01 10:36:05.818+02	2026-06-01 10:36:05.818+02	\N	\N
variant_01KT156V1RTTF8ZFM532ZHY478	Blue / 37	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	prod_01KT156V00QYP2NS7HYG4BWMYG	2026-06-01 10:36:05.818+02	2026-06-01 10:36:05.818+02	\N	\N
variant_01KT156V1R0W7QGY9RZ0AFW25G	Blue / 36	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	prod_01KT156V00QYP2NS7HYG4BWMYG	2026-06-01 10:36:05.818+02	2026-06-01 10:36:05.818+02	\N	\N
variant_01KT156V1R33TNWGM1H7YV0QK8	Blue / 35	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	prod_01KT156V00QYP2NS7HYG4BWMYG	2026-06-01 10:36:05.818+02	2026-06-01 10:36:05.818+02	\N	\N
variant_01KT156V1R89CA2Y8H3AH9YV1B	vert / 39	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	prod_01KT156V00QYP2NS7HYG4BWMYG	2026-06-01 10:36:05.818+02	2026-06-01 10:36:05.818+02	\N	\N
variant_01KT156V1RRDQ96ZYAC7T058WN	vert / 37	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	prod_01KT156V00QYP2NS7HYG4BWMYG	2026-06-01 10:36:05.818+02	2026-06-01 10:36:05.818+02	\N	\N
variant_01KT156V1SD23PGB9TGKF13SWS	vert / 36	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	10	prod_01KT156V00QYP2NS7HYG4BWMYG	2026-06-01 10:36:05.818+02	2026-06-01 10:36:05.818+02	\N	\N
variant_01KT156V1S9VHZR8HT8193DZ8Z	vert / 35	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	prod_01KT156V00QYP2NS7HYG4BWMYG	2026-06-01 10:36:05.818+02	2026-06-01 10:36:05.818+02	\N	\N
variant_01KTJ4E452HDB1ARE48S9FRW6B	Default variant	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KTJ4E43N2WV9BNRB99A9XMED	2026-06-08 00:49:41.283+02	2026-06-08 00:52:07.306+02	2026-06-08 00:52:07.278+02	\N
variant_01KTJ4K78R58KXSVS5BHXX5F4Y	Default variant	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KTJ4K77CRV73SNDHAGTJSC32	2026-06-08 00:52:28.313+02	2026-06-08 01:10:45.826+02	2026-06-08 01:10:45.808+02	\N
variant_01KV5D7S7XGAA4YZSHQ0ACR1DZ	Rouge	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KV5D7S5A3GT3TNV6JJ36QA88	2026-06-15 12:29:04.894+02	2026-06-15 12:29:04.894+02	\N	\N
variant_01KV5D7S7XPY4RGQ25F30C8SFN	Vert	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	prod_01KV5D7S5A3GT3TNV6JJ36QA88	2026-06-15 12:29:04.895+02	2026-06-15 12:29:04.895+02	\N	\N
variant_01KV5D7S7Y5BPNZK7FRBTSZKQW	Noire	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	prod_01KV5D7S5A3GT3TNV6JJ36QA88	2026-06-15 12:29:04.895+02	2026-06-15 12:29:04.895+02	\N	\N
variant_01KV5DPWSCN3T6MAJ0GYN5HP8H	Default variant	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KV5DPWQMJ87E724G2PHS05ZZ	2026-06-15 12:37:20.045+02	2026-06-15 12:37:20.045+02	\N	\N
variant_01KV5E602RNH70N1K2VTF7GA0D	Default variant	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KV5E601185BKG901X7QG2CEW	2026-06-15 12:45:34.936+02	2026-06-15 12:45:34.936+02	\N	\N
variant_01KV5H8J2SS3M2Q24QZY9N1146	Default variant	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KV5H8J0X1ZXZA46EZ0MG683D	2026-06-15 13:39:24.634+02	2026-06-15 13:39:24.634+02	\N	\N
variant_01KV5K1Y7YYFQVWGAWEBNRGXB9	Rouge	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KV5JR733EB6YJ4A4G4TNYWNN.jpg"}	0	prod_01KV5K1Y66BRSD3K4GDMN4M1YS	2026-06-15 14:10:44.863+02	2026-06-15 14:10:44.863+02	\N	\N
variant_01KV5K1Y7ZB131EVPGZ9M407MM	Noire	BBBB	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KV5JS3PFQVEDVEBS0NP2MC1X.jpg"}	2	prod_01KV5K1Y66BRSD3K4GDMN4M1YS	2026-06-15 14:10:44.863+02	2026-06-15 14:10:44.863+02	\N	\N
variant_01KV5K1Y7Y8GVH4HFJ28G7C2ST	Vert	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KV5JRRG20A80BP2B80ZTSC29.jpg"}	1	prod_01KV5K1Y66BRSD3K4GDMN4M1YS	2026-06-15 14:10:44.863+02	2026-06-15 14:10:44.863+02	\N	\N
variant_01KV5DWPP9MHKVNJ2J9TVRHFQF	Default variant	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KV5DWPN1992BC1RARAP2H0K1	2026-06-15 12:40:30.41+02	2026-06-15 12:40:30.41+02	\N	\N
variant_01KVAHVT2EBVYQBAVTR9ZSV73R	36 / Rouge	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KVAGYGR5HSSKB5HN5VY7MM8M.jpg"}	0	prod_01KVAHVT1115P37Z781SCQWX1W	2026-06-17 12:26:07.57+02	2026-06-17 12:26:07.57+02	\N	\N
variant_01KVAHVT2EFGQC5VJRK8VZ2D16	36 / Rose	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KVAGYX2XRGSEM2ZN3RB25A0F.jpg"}	2	prod_01KVAHVT1115P37Z781SCQWX1W	2026-06-17 12:26:07.57+02	2026-06-17 12:26:07.57+02	\N	\N
variant_01KVAHVT2EKW039PVGG0YMCKJ1	36 / Noir	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KVAGYPYRM3KFMN1MA1V79MRR.jpg"}	1	prod_01KVAHVT1115P37Z781SCQWX1W	2026-06-17 12:26:07.57+02	2026-06-17 12:26:07.57+02	\N	\N
variant_01KVAHVT2G8EYFH7877KZ9P609	41 / Rose	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KVAGZ43DAF3T23CHD6X0QKV2.jpg"}	17	prod_01KVAHVT1115P37Z781SCQWX1W	2026-06-17 12:26:07.571+02	2026-06-17 12:26:07.571+02	\N	\N
variant_01KVAHVT2GG8P6AH8R8HFEZH0E	41 / Rouge	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KVAGYX2XRGSEM2ZN3RB25A0F.jpg"}	15	prod_01KVAHVT1115P37Z781SCQWX1W	2026-06-17 12:26:07.571+02	2026-06-17 12:26:07.571+02	\N	\N
variant_01KVAHVT2GSFK731WQE0KHHMD7	42 / Rouge	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KVAGYX2XRGSEM2ZN3RB25A0F.jpg"}	18	prod_01KVAHVT1115P37Z781SCQWX1W	2026-06-17 12:26:07.571+02	2026-06-17 12:26:07.571+02	\N	\N
variant_01KVAHVT2GQ7RSYTG6CVBR86D7	41 / Noir	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KVAGZKST84XXRAN5XP6E6K3D.jpg"}	16	prod_01KVAHVT1115P37Z781SCQWX1W	2026-06-17 12:26:07.571+02	2026-06-17 12:26:07.571+02	\N	\N
variant_01KVAHVT2GZ68V2K3DP2W36T40	40 / Rose	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KVAGYPYRM3KFMN1MA1V79MRR.jpg"}	14	prod_01KVAHVT1115P37Z781SCQWX1W	2026-06-17 12:26:07.571+02	2026-06-17 12:26:07.571+02	\N	\N
variant_01KVAHVT2GAH734RVEBJFDYTW5	40 / Noir	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KVAGYPYRM3KFMN1MA1V79MRR.jpg"}	13	prod_01KVAHVT1115P37Z781SCQWX1W	2026-06-17 12:26:07.57+02	2026-06-17 12:26:07.57+02	\N	\N
variant_01KVAHVT2G0Z84AKT0PB02B7WB	39 / Rose	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KVAGYX2XRGSEM2ZN3RB25A0F.jpg"}	11	prod_01KVAHVT1115P37Z781SCQWX1W	2026-06-17 12:26:07.57+02	2026-06-17 12:26:07.57+02	\N	\N
variant_01KVAHVT2GP4TRP54275NTZTNN	40 / Rouge	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KVAGZ9R2R5DZ7KRJTQ6V1B59.jpg"}	12	prod_01KVAHVT1115P37Z781SCQWX1W	2026-06-17 12:26:07.57+02	2026-06-17 12:26:07.57+02	\N	\N
variant_01KVAHVT2F31911T068HKBAC4T	39 / Noir	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KVAGZKST84XXRAN5XP6E6K3D.jpg"}	10	prod_01KVAHVT1115P37Z781SCQWX1W	2026-06-17 12:26:07.57+02	2026-06-17 12:26:07.57+02	\N	\N
variant_01KVAHVT2F8CPCVV47YJ2SGPJG	39 / Rouge	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KVAGZFYG7VA6J6XXHBVHFNSH.jpg"}	9	prod_01KVAHVT1115P37Z781SCQWX1W	2026-06-17 12:26:07.57+02	2026-06-17 12:26:07.57+02	\N	\N
variant_01KVAHVT2FG61XFHY82W48YTQB	38 / Rose	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KVAGYX2XRGSEM2ZN3RB25A0F.jpg"}	8	prod_01KVAHVT1115P37Z781SCQWX1W	2026-06-17 12:26:07.57+02	2026-06-17 12:26:07.57+02	\N	\N
variant_01KVAHVT2F55NN49QV71ND47S1	38 / Rouge	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KVAGYGR5HSSKB5HN5VY7MM8M.jpg"}	6	prod_01KVAHVT1115P37Z781SCQWX1W	2026-06-17 12:26:07.57+02	2026-06-17 12:26:07.57+02	\N	\N
variant_01KVAHVT2FM2YBRCS7RT6W7JDQ	38 / Noir	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KVAGZ43DAF3T23CHD6X0QKV2.jpg"}	7	prod_01KVAHVT1115P37Z781SCQWX1W	2026-06-17 12:26:07.57+02	2026-06-17 12:26:07.57+02	\N	\N
variant_01KVAHVT2F88YAB61SD8RNZ35Z	37 / Rose	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KVAGYX2XRGSEM2ZN3RB25A0F.jpg"}	5	prod_01KVAHVT1115P37Z781SCQWX1W	2026-06-17 12:26:07.57+02	2026-06-17 12:26:07.57+02	\N	\N
variant_01KVAHVT2EP90KV9WDPRH9JG0C	37 / Noir	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KVAGYX2XRGSEM2ZN3RB25A0F.jpg"}	4	prod_01KVAHVT1115P37Z781SCQWX1W	2026-06-17 12:26:07.57+02	2026-06-17 12:26:07.57+02	\N	\N
variant_01KVAHVT2EC2B5PDWT67B8XB71	37 / Rouge	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KVAGZ43DAF3T23CHD6X0QKV2.jpg"}	3	prod_01KVAHVT1115P37Z781SCQWX1W	2026-06-17 12:26:07.57+02	2026-06-17 12:26:07.57+02	\N	\N
variant_01KVAHVT2JVPEVJA8HAW31CY3R	42 / Rose	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KVAGZKST84XXRAN5XP6E6K3D.jpg"}	20	prod_01KVAHVT1115P37Z781SCQWX1W	2026-06-17 12:26:07.571+02	2026-06-17 12:26:07.571+02	\N	\N
variant_01KVAHVT2JSBEBNQN7AQ4HWWV8	42 / Noir	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KVAGZKST84XXRAN5XP6E6K3D.jpg"}	19	prod_01KVAHVT1115P37Z781SCQWX1W	2026-06-17 12:26:07.571+02	2026-06-17 12:26:07.571+02	\N	\N
variant_01KVANBHZT17X97GMN7H90KG4H	Default variant	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01KVANBHYVPHYHTH3VKVZDF1VJ	2026-06-17 13:27:09.306+02	2026-06-17 13:27:09.306+02	\N	\N
variant_01KWTKZBP0CNV7C3N5X7799R31	36	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KWTKVV2H2M65YENN1QQ6EMKH.jpg"}	0	prod_01KWTKZBN13GNZVP6YNBMAD3VP	2026-07-06 04:26:33.792+02	2026-07-06 04:26:33.792+02	\N	\N
variant_01KWTKZBP0T469V7GSXHBYCA06	37	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KWTKVWVJR0PWJ3R2MG7VGZP2.jpg"}	1	prod_01KWTKZBN13GNZVP6YNBMAD3VP	2026-07-06 04:26:33.792+02	2026-07-06 04:26:33.792+02	\N	\N
variant_01KWTKZBP0ZM5SKYT8FF8TRK05	38	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KWTKW21BZ3D6CNEKF6J5XZB0.jpg"}	2	prod_01KWTKZBN13GNZVP6YNBMAD3VP	2026-07-06 04:26:33.792+02	2026-07-06 04:26:33.792+02	\N	\N
variant_01KWT4YC09506GRNFD29SZ1RFP	37	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	prod_01KWT4YBXAFKGSHX0R820VDJS4	2026-07-06 00:03:52.715+02	2026-07-06 04:22:16.266+02	2026-07-06 04:22:16.259+02	\N
variant_01KWT4YC0ADA44FBSQ409TSB9C	40	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	prod_01KWT4YBXAFKGSHX0R820VDJS4	2026-07-06 00:03:52.715+02	2026-07-06 04:22:16.266+02	2026-07-06 04:22:16.259+02	\N
variant_01KWT4YC09NXR46MJEBHPSV5F3	38	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	prod_01KWT4YBXAFKGSHX0R820VDJS4	2026-07-06 00:03:52.715+02	2026-07-06 04:22:16.266+02	2026-07-06 04:22:16.259+02	\N
variant_01KWT4YC08GHVNG1VSZDQVEJ4K	36	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"image": "https://s3.eastmarket.africa/eastmarket/image-01KWT4FXDQ78MMRJQZR3G7FVA4.jpg"}	0	prod_01KWT4YBXAFKGSHX0R820VDJS4	2026-07-06 00:03:52.714+02	2026-07-06 04:22:16.266+02	2026-07-06 04:22:16.259+02	\N
variant_01KWT4YC09SDR7B73TQTD3N1AF	39	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	prod_01KWT4YBXAFKGSHX0R820VDJS4	2026-07-06 00:03:52.715+02	2026-07-06 04:22:16.266+02	2026-07-06 04:22:16.259+02	\N
\.


--
-- Data for Name: product_variant_inventory_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_variant_inventory_item (variant_id, inventory_item_id, id, required_quantity, created_at, updated_at, deleted_at) FROM stdin;
variant_01KSCR9EBB5SDB79TPFJJ35HPP	iitem_01KSCR9EC0PDSZC7VWWAAGC01V	pvitem_01KSCR9ECBV1TX3AT273YZZBWP	1	2026-05-24 12:25:31.019139+02	2026-05-24 12:25:31.019139+02	\N
variant_01KSCR9EBCY91XPNSCP8NXT8F2	iitem_01KSCR9EC1HB8C05V1RH1RQR94	pvitem_01KSCR9ECB1J9JNTGS94NTSYRJ	1	2026-05-24 12:25:31.019139+02	2026-05-24 12:25:31.019139+02	\N
variant_01KSCR9EBC52MBRCSV877TQXP5	iitem_01KSCR9EC17E675WBKDD899K3M	pvitem_01KSCR9ECBJFQBNG8FGC8C4YPZ	1	2026-05-24 12:25:31.019139+02	2026-05-24 12:25:31.019139+02	\N
variant_01KSCR9EBC5YZVT1MZ87Z9R80B	iitem_01KSCR9EC120WWXK3AG603G67K	pvitem_01KSCR9ECBH03MDATCAV48DDXP	1	2026-05-24 12:25:31.019139+02	2026-05-24 12:25:31.019139+02	\N
variant_01KSCR9EBCRNX20J9HW4HNEJ8H	iitem_01KSCR9EC1FD0YB5N181ZEN081	pvitem_01KSCR9ECBGQTGG3DFVR41F7JJ	1	2026-05-24 12:25:31.019139+02	2026-05-24 12:25:31.019139+02	\N
variant_01KSCR9EBCTFGSPR2Y2E5TN1FE	iitem_01KSCR9EC1C7TWEQCB8E7ANMF8	pvitem_01KSCR9ECBJ680E8E4ZBWJAA5G	1	2026-05-24 12:25:31.019139+02	2026-05-24 12:25:31.019139+02	\N
variant_01KSCR9EBC5APY2TXMQGMBGJJR	iitem_01KSCR9EC1ZGRZB2CBZENPWJC4	pvitem_01KSCR9ECBE975SWHSFKCD60ZN	1	2026-05-24 12:25:31.019139+02	2026-05-24 12:25:31.019139+02	\N
variant_01KSCR9EBCN34947HRNE0YX51J	iitem_01KSCR9EC1Y0GE50A6RKZ6Q7RP	pvitem_01KSCR9ECBRBTHYPNB6C12XTKN	1	2026-05-24 12:25:31.019139+02	2026-05-24 12:25:31.019139+02	\N
variant_01KSCR9EBCE6BWGPAF65WMKV0A	iitem_01KSCR9EC1HSBCQ0QMXEN4Y7A9	pvitem_01KSCR9ECBVZS9M3H1WR98ZTVF	1	2026-05-24 12:25:31.019139+02	2026-05-24 12:25:31.019139+02	\N
variant_01KSCR9EBCNMMZ5Y3Q1Y4JDWPF	iitem_01KSCR9EC19VPAMPAK41R1AX86	pvitem_01KSCR9ECBKEJ2BH33A8TZF4J7	1	2026-05-24 12:25:31.019139+02	2026-05-24 12:25:31.019139+02	\N
variant_01KSCR9EBCXS1X5N5HFAWFFBF4	iitem_01KSCR9EC1R6QJAGR69RNSMBJ1	pvitem_01KSCR9ECCC6TE84J9DH2X7XN6	1	2026-05-24 12:25:31.019139+02	2026-05-24 12:25:31.019139+02	\N
variant_01KSCR9EBCMJZVF6QQHWN7X7WQ	iitem_01KSCR9EC1D0M5XFY3BQ62XBSV	pvitem_01KSCR9ECC5YYYRX81TDZVY1JC	1	2026-05-24 12:25:31.019139+02	2026-05-24 12:25:31.019139+02	\N
variant_01KSCR9EBC6H04N5PNKAG5YYAA	iitem_01KSCR9EC19HVS03GFEAGTK8GE	pvitem_01KSCR9ECC48TH6T8Y7NMXEEXB	1	2026-05-24 12:25:31.019139+02	2026-05-24 12:25:31.019139+02	\N
variant_01KSCR9EBCYVV229KF5B1DHB0P	iitem_01KSCR9EC1Y6XET4SWJZTD8A51	pvitem_01KSCR9ECC6QQEN1KM5F1JW0QG	1	2026-05-24 12:25:31.019139+02	2026-05-24 12:25:31.019139+02	\N
variant_01KSCR9EBCPQ162CT8P8JYJ208	iitem_01KSCR9EC19RHJJ2JFRZ6MPYC5	pvitem_01KSCR9ECCP3J93A9Y9CB4XY87	1	2026-05-24 12:25:31.019139+02	2026-05-24 12:25:31.019139+02	\N
variant_01KSCR9EBC6292NXWNKFT12BMR	iitem_01KSCR9EC1V12YZ884F88NY22W	pvitem_01KSCR9ECC8PTBH4QANNCM1YV5	1	2026-05-24 12:25:31.019139+02	2026-05-24 12:25:31.019139+02	\N
variant_01KSCR9EBD5ARPWGHVT9C1YYH2	iitem_01KSCR9EC1XRJ5M4ZFVCTDPSBY	pvitem_01KSCR9ECC1ZJ7SPR1NKB6Y6ZC	1	2026-05-24 12:25:31.019139+02	2026-05-24 12:25:31.019139+02	\N
variant_01KSCR9EBD48FCYXEHZ28PQTG1	iitem_01KSCR9EC166N0FB3G0HQ0PVBJ	pvitem_01KSCR9ECC4D89V9Z84QCZ1S3G	1	2026-05-24 12:25:31.019139+02	2026-05-24 12:25:31.019139+02	\N
variant_01KSCR9EBDR67KBGB0BSV76Z1Q	iitem_01KSCR9EC1B45Y7RQ5WT4VHDCX	pvitem_01KSCR9ECCXVWQTCD3BAJEWV97	1	2026-05-24 12:25:31.019139+02	2026-05-24 12:25:31.019139+02	\N
variant_01KSCR9EBDQEQRFWFY9KZ76VHQ	iitem_01KSCR9EC1KZA0Y28HQF7XS00J	pvitem_01KSCR9ECCD689VJVM2DB7TCZ3	1	2026-05-24 12:25:31.019139+02	2026-05-24 12:25:31.019139+02	\N
variant_01KSDEEB4X5XQS5EZAMWG8KH96	iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	pvitem_01KSDEEB5B67SX69D80960DF43	1	2026-05-24 18:52:40.235382+02	2026-05-24 18:52:40.235382+02	\N
variant_01KSDEEB4Y5FRC1M9K6A8SS7E4	iitem_01KSDEEB53H2NY8JN5MZ4NZBX4	pvitem_01KSDEEB5CZTB83TB0CDVVS3F8	1	2026-05-24 18:52:40.235382+02	2026-05-24 18:52:40.235382+02	\N
variant_01KSH2A902V793W1CP9H7Y6ZMT	iitem_01KSH2A90AXJP1WGVK31SDGQ0C	pvitem_01KSH2A90HYGJQPTZ0YK140H20	1	2026-05-26 04:37:41.77716+02	2026-05-26 04:37:41.77716+02	\N
variant_01KT156V1Q6CDQTENG754WVA87	iitem_01KT156V2D9BDG54AYY9EGRDTX	pvitem_01KT156V38P2B3TGKXH45BZ56T	1	2026-06-01 10:36:05.86341+02	2026-06-01 10:36:05.86341+02	\N
variant_01KT156V1QEBNZXXPH2KM55161	iitem_01KT156V2ESTBNPRTZCNJCE1YK	pvitem_01KT156V38FRP34EQ1KV5J5814	1	2026-06-01 10:36:05.86341+02	2026-06-01 10:36:05.86341+02	\N
variant_01KT156V1QZZFWVV6M8QH9QATX	iitem_01KT156V2EC7S24TG3RN8VRQ3Q	pvitem_01KT156V39AKBZ6JMHB4ZWVQHV	1	2026-06-01 10:36:05.86341+02	2026-06-01 10:36:05.86341+02	\N
variant_01KT156V1RSWV24EF942MK1XM1	iitem_01KT156V2EXS7RRW8FEFBXP4ZC	pvitem_01KT156V39QR424ADP4AD3C7QP	1	2026-06-01 10:36:05.86341+02	2026-06-01 10:36:05.86341+02	\N
variant_01KT156V1RDGKYWHTKBZ5AEPKA	iitem_01KT156V2E8YRFAZ8CZMNENNRH	pvitem_01KT156V3961ZWBK4F4Q17SQFD	1	2026-06-01 10:36:05.86341+02	2026-06-01 10:36:05.86341+02	\N
variant_01KT156V1RTTF8ZFM532ZHY478	iitem_01KT156V2EXY4QQ2R4KG9EBAPC	pvitem_01KT156V39SVJR8Z4PK5HSP0KT	1	2026-06-01 10:36:05.86341+02	2026-06-01 10:36:05.86341+02	\N
variant_01KT156V1R0W7QGY9RZ0AFW25G	iitem_01KT156V2EKDZX0SXDVKPWFSHQ	pvitem_01KT156V398T81HMDSFFZGBP1W	1	2026-06-01 10:36:05.86341+02	2026-06-01 10:36:05.86341+02	\N
variant_01KT156V1R33TNWGM1H7YV0QK8	iitem_01KT156V2EVHR7QXFSPK6RY4YV	pvitem_01KT156V39X7AKQKDAQQ8VSGBH	1	2026-06-01 10:36:05.86341+02	2026-06-01 10:36:05.86341+02	\N
variant_01KT156V1R89CA2Y8H3AH9YV1B	iitem_01KT156V2E7PC7RQDA6B8FWM85	pvitem_01KT156V39C5T7YPSTQ4E84GYQ	1	2026-06-01 10:36:05.86341+02	2026-06-01 10:36:05.86341+02	\N
variant_01KT156V1RRDQ96ZYAC7T058WN	iitem_01KT156V2EKD9ESXV7R28GXCAS	pvitem_01KT156V3996VTQBFWGJ05ZWZF	1	2026-06-01 10:36:05.86341+02	2026-06-01 10:36:05.86341+02	\N
variant_01KT156V1SD23PGB9TGKF13SWS	iitem_01KT156V2EX8VC55F19CTQAXS7	pvitem_01KT156V39NRQHS22NWV9ZFT4W	1	2026-06-01 10:36:05.86341+02	2026-06-01 10:36:05.86341+02	\N
variant_01KT156V1S9VHZR8HT8193DZ8Z	iitem_01KT156V2E1837VDVNJP7FPRT0	pvitem_01KT156V39JDGWN0WQ79ECVNM8	1	2026-06-01 10:36:05.86341+02	2026-06-01 10:36:05.86341+02	\N
variant_01KV5D7S7XGAA4YZSHQ0ACR1DZ	iitem_01KV5D7S8NVB2A9Z0KYW0E88BB	pvitem_01KV5D7S9C71DSZT57M0RVQRRA	1	2026-06-15 12:29:04.939869+02	2026-06-15 12:29:04.939869+02	\N
variant_01KV5D7S7XPY4RGQ25F30C8SFN	iitem_01KV5D7S8NAANSQE6PWP50PFRD	pvitem_01KV5D7S9D6VG82PNPBQWCWQNP	1	2026-06-15 12:29:04.939869+02	2026-06-15 12:29:04.939869+02	\N
variant_01KV5D7S7Y5BPNZK7FRBTSZKQW	iitem_01KV5D7S8NTWY0KMPEE92AJJDY	pvitem_01KV5D7S9DX6X9MR8ZQF5TJPKC	1	2026-06-15 12:29:04.939869+02	2026-06-15 12:29:04.939869+02	\N
variant_01KV5DPWSCN3T6MAJ0GYN5HP8H	iitem_01KV5DPWSPTST7FXX39EXJRFF0	pvitem_01KV5DPWSZ32SG955TW688SDE8	1	2026-06-15 12:37:20.063174+02	2026-06-15 12:37:20.063174+02	\N
variant_01KV5DWPP9MHKVNJ2J9TVRHFQF	iitem_01KV5DWPPMJZPADJJEVDXN4WVJ	pvitem_01KV5DWPQ0RH6KXW3YJSVSHG07	1	2026-06-15 12:40:30.432099+02	2026-06-15 12:40:30.432099+02	\N
variant_01KV5E602RNH70N1K2VTF7GA0D	iitem_01KV5E6037BBN8QYW3D413M04V	pvitem_01KV5E603TFVAJM88XKX1YVP4E	1	2026-06-15 12:45:34.970308+02	2026-06-15 12:45:34.970308+02	\N
variant_01KV5H8J2SS3M2Q24QZY9N1146	iitem_01KV5H8J354V8SCWQZ6YKFFKRE	pvitem_01KV5H8J3KCV1CAN1P2CAZ217Z	1	2026-06-15 13:39:24.659289+02	2026-06-15 13:39:24.659289+02	\N
variant_01KV5K1Y7YYFQVWGAWEBNRGXB9	iitem_01KV5K1Y8CXCPK0QCBM7EJD12F	pvitem_01KV5K1Y8TPMWGJX5ZNQCKG12S	1	2026-06-15 14:10:44.88964+02	2026-06-15 14:10:44.88964+02	\N
variant_01KV5K1Y7Y8GVH4HFJ28G7C2ST	iitem_01KV5K1Y8C7Z9E7KPDYKTVSXCT	pvitem_01KV5K1Y8T1S0T64GNPVP33JMN	1	2026-06-15 14:10:44.88964+02	2026-06-15 14:10:44.88964+02	\N
variant_01KV5K1Y7ZB131EVPGZ9M407MM	iitem_01KV5K1Y8C1YHWAF1KDMADDJFP	pvitem_01KV5K1Y8THKAKEVF8K5T8NW51	1	2026-06-15 14:10:44.88964+02	2026-06-15 14:10:44.88964+02	\N
variant_01KVAHVT2EBVYQBAVTR9ZSV73R	iitem_01KVAHVT37TKMYG16FDY59N069	pvitem_01KVAHVT3QHPDH3W76EQV0GW72	1	2026-06-17 12:26:07.607711+02	2026-06-17 12:26:07.607711+02	\N
variant_01KVAHVT2EKW039PVGG0YMCKJ1	iitem_01KVAHVT374ZMFAHPT202HD53G	pvitem_01KVAHVT3RJD1TT9TBT40WRFHM	1	2026-06-17 12:26:07.607711+02	2026-06-17 12:26:07.607711+02	\N
variant_01KVAHVT2EFGQC5VJRK8VZ2D16	iitem_01KVAHVT37SFJRAPFHZQPJJ5GA	pvitem_01KVAHVT3RSSGP5M3F01BPVR8Y	1	2026-06-17 12:26:07.607711+02	2026-06-17 12:26:07.607711+02	\N
variant_01KVAHVT2EC2B5PDWT67B8XB71	iitem_01KVAHVT37BDF49THXG5DZSX7M	pvitem_01KVAHVT3RS385VVGTNBC6R96M	1	2026-06-17 12:26:07.607711+02	2026-06-17 12:26:07.607711+02	\N
variant_01KVAHVT2EP90KV9WDPRH9JG0C	iitem_01KVAHVT375Q8HN5BBDTX5C71B	pvitem_01KVAHVT3RWG4Y6MV75XWN4N88	1	2026-06-17 12:26:07.607711+02	2026-06-17 12:26:07.607711+02	\N
variant_01KVAHVT2F88YAB61SD8RNZ35Z	iitem_01KVAHVT3744EGEW6G5DSZDBJ9	pvitem_01KVAHVT3RM3F21DRM3T9KZBJQ	1	2026-06-17 12:26:07.607711+02	2026-06-17 12:26:07.607711+02	\N
variant_01KVAHVT2F55NN49QV71ND47S1	iitem_01KVAHVT38NFKZY1X85C0VYZSD	pvitem_01KVAHVT3RS19N4Y2FRDYG65FV	1	2026-06-17 12:26:07.607711+02	2026-06-17 12:26:07.607711+02	\N
variant_01KVAHVT2FM2YBRCS7RT6W7JDQ	iitem_01KVAHVT38ZCG81XQ3H5KEHA0V	pvitem_01KVAHVT3RT315AXA2KSDCHZ2Y	1	2026-06-17 12:26:07.607711+02	2026-06-17 12:26:07.607711+02	\N
variant_01KVAHVT2FG61XFHY82W48YTQB	iitem_01KVAHVT38WBN8M5J7YY3Y4P7E	pvitem_01KVAHVT3RZK6TFRB1KA5A9T56	1	2026-06-17 12:26:07.607711+02	2026-06-17 12:26:07.607711+02	\N
variant_01KVAHVT2F8CPCVV47YJ2SGPJG	iitem_01KVAHVT38K5CQG715E85GQHW1	pvitem_01KVAHVT3SR5X27XZG87SX2PNH	1	2026-06-17 12:26:07.607711+02	2026-06-17 12:26:07.607711+02	\N
variant_01KVAHVT2F31911T068HKBAC4T	iitem_01KVAHVT38256GPWHFJF7KKT3G	pvitem_01KVAHVT3S6BQX0J3AXCPR65QV	1	2026-06-17 12:26:07.607711+02	2026-06-17 12:26:07.607711+02	\N
variant_01KVAHVT2G0Z84AKT0PB02B7WB	iitem_01KVAHVT38NJ00QJ8GMJVKJAG2	pvitem_01KVAHVT3SZGPHD1QA2EAC0RGY	1	2026-06-17 12:26:07.607711+02	2026-06-17 12:26:07.607711+02	\N
variant_01KVAHVT2GP4TRP54275NTZTNN	iitem_01KVAHVT38GAV7S0XRX4E2D380	pvitem_01KVAHVT3SAMCFVCCZ9B59DK2D	1	2026-06-17 12:26:07.607711+02	2026-06-17 12:26:07.607711+02	\N
variant_01KVAHVT2GAH734RVEBJFDYTW5	iitem_01KVAHVT38SWM4E7PVNTXZWT5P	pvitem_01KVAHVT3SDW5KHQTQ32D3G2B5	1	2026-06-17 12:26:07.607711+02	2026-06-17 12:26:07.607711+02	\N
variant_01KVAHVT2GZ68V2K3DP2W36T40	iitem_01KVAHVT3898CBHZBCQ0MPR26R	pvitem_01KVAHVT3SKV1BTEQ8X47JW6VV	1	2026-06-17 12:26:07.607711+02	2026-06-17 12:26:07.607711+02	\N
variant_01KVAHVT2GG8P6AH8R8HFEZH0E	iitem_01KVAHVT38X0SVH0WF33CRPXG6	pvitem_01KVAHVT3SQMZ4M9SZB9WPTMJJ	1	2026-06-17 12:26:07.607711+02	2026-06-17 12:26:07.607711+02	\N
variant_01KVAHVT2GQ7RSYTG6CVBR86D7	iitem_01KVAHVT382SRSCR7DMZRZVJ5D	pvitem_01KVAHVT3S7FBHJQY9E8D9PTZ9	1	2026-06-17 12:26:07.607711+02	2026-06-17 12:26:07.607711+02	\N
variant_01KVAHVT2G8EYFH7877KZ9P609	iitem_01KVAHVT38WDH8XQM2W8K050NM	pvitem_01KVAHVT3SDV9EAWYF32HQTZER	1	2026-06-17 12:26:07.607711+02	2026-06-17 12:26:07.607711+02	\N
variant_01KVAHVT2GSFK731WQE0KHHMD7	iitem_01KVAHVT38WVAJH847VHE24N33	pvitem_01KVAHVT3S3EN7329ZCXH0EAVS	1	2026-06-17 12:26:07.607711+02	2026-06-17 12:26:07.607711+02	\N
variant_01KVAHVT2JSBEBNQN7AQ4HWWV8	iitem_01KVAHVT38G2JSD9BP22ZF4JY7	pvitem_01KVAHVT3SFMKFJGFN8S74K6YF	1	2026-06-17 12:26:07.607711+02	2026-06-17 12:26:07.607711+02	\N
variant_01KVAHVT2JVPEVJA8HAW31CY3R	iitem_01KVAHVT39H53C00SFZRERAJF8	pvitem_01KVAHVT3SERRE7ANGKBTDDEMN	1	2026-06-17 12:26:07.607711+02	2026-06-17 12:26:07.607711+02	\N
variant_01KVANBHZT17X97GMN7H90KG4H	iitem_01KVANBHZZK8M0CGKMSY29DN4N	pvitem_01KVANBJ05XMZNP1TPP59VJBHH	1	2026-06-17 13:27:09.317736+02	2026-06-17 13:27:09.317736+02	\N
variant_01KWT4YC08GHVNG1VSZDQVEJ4K	iitem_01KWT4YC194V5VY2BDXKX4RB53	pvitem_01KWT4YC24FJ9R3Z0EVJZAY6JE	1	2026-07-06 00:03:52.772017+02	2026-07-06 04:22:16.254+02	2026-07-06 04:22:16.254+02
variant_01KWT4YC09506GRNFD29SZ1RFP	iitem_01KWT4YC196BA6Y9YSTR65BNMQ	pvitem_01KWT4YC25YV7E8AEVXJ6FJ104	1	2026-07-06 00:03:52.772017+02	2026-07-06 04:22:16.254+02	2026-07-06 04:22:16.254+02
variant_01KWT4YC09NXR46MJEBHPSV5F3	iitem_01KWT4YC198NW967WS87CJ00ZP	pvitem_01KWT4YC258Q35GD7QX48A6T3S	1	2026-07-06 00:03:52.772017+02	2026-07-06 04:22:16.254+02	2026-07-06 04:22:16.254+02
variant_01KWT4YC09SDR7B73TQTD3N1AF	iitem_01KWT4YC19JZ4236W1BZ275EYY	pvitem_01KWT4YC250JE53G37A6RS2SXY	1	2026-07-06 00:03:52.772017+02	2026-07-06 04:22:16.254+02	2026-07-06 04:22:16.254+02
variant_01KWT4YC0ADA44FBSQ409TSB9C	iitem_01KWT4YC192WYH9RA7ZNNTK11F	pvitem_01KWT4YC2594GPCPB3P09G0AK9	1	2026-07-06 00:03:52.772017+02	2026-07-06 04:22:16.254+02	2026-07-06 04:22:16.254+02
variant_01KWTKZBP0CNV7C3N5X7799R31	iitem_01KWTKZBP95E8ZW505Y83TMT5K	pvitem_01KWTKZBPJ8JV5ZNTARK7H27DK	1	2026-07-06 04:26:33.810686+02	2026-07-06 04:26:33.810686+02	\N
variant_01KWTKZBP0T469V7GSXHBYCA06	iitem_01KWTKZBP978S4H4NS162WJTKP	pvitem_01KWTKZBPKH58F4C2GJXNSNGSK	1	2026-07-06 04:26:33.810686+02	2026-07-06 04:26:33.810686+02	\N
variant_01KWTKZBP0ZM5SKYT8FF8TRK05	iitem_01KWTKZBP90TH06VGPXFRVR0WF	pvitem_01KWTKZBPK8RFKT9WMGRRKS12W	1	2026-07-06 04:26:33.810686+02	2026-07-06 04:26:33.810686+02	\N
\.


--
-- Data for Name: product_variant_option; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_variant_option (variant_id, option_value_id) FROM stdin;
variant_01KSCR9EBB5SDB79TPFJJ35HPP	optval_01KSCR9EAAPK0DPVZZV7061DD3
variant_01KSCR9EBB5SDB79TPFJJ35HPP	optval_01KSCR9EAAY43F9VW0PYAKVVDY
variant_01KSCR9EBCY91XPNSCP8NXT8F2	optval_01KSCR9EAAPK0DPVZZV7061DD3
variant_01KSCR9EBCY91XPNSCP8NXT8F2	optval_01KSCR9EAAWS50R4TEENNCTFAS
variant_01KSCR9EBC52MBRCSV877TQXP5	optval_01KSCR9EAAA6SZKS2ADX58ETH3
variant_01KSCR9EBC52MBRCSV877TQXP5	optval_01KSCR9EAAY43F9VW0PYAKVVDY
variant_01KSCR9EBC5YZVT1MZ87Z9R80B	optval_01KSCR9EAAA6SZKS2ADX58ETH3
variant_01KSCR9EBC5YZVT1MZ87Z9R80B	optval_01KSCR9EAAWS50R4TEENNCTFAS
variant_01KSCR9EBCRNX20J9HW4HNEJ8H	optval_01KSCR9EAAXMECRFD50M4VZBK5
variant_01KSCR9EBCRNX20J9HW4HNEJ8H	optval_01KSCR9EAAY43F9VW0PYAKVVDY
variant_01KSCR9EBCTFGSPR2Y2E5TN1FE	optval_01KSCR9EAAXMECRFD50M4VZBK5
variant_01KSCR9EBCTFGSPR2Y2E5TN1FE	optval_01KSCR9EAAWS50R4TEENNCTFAS
variant_01KSCR9EBC5APY2TXMQGMBGJJR	optval_01KSCR9EAATZB8J567B1H5ZYGN
variant_01KSCR9EBC5APY2TXMQGMBGJJR	optval_01KSCR9EAAY43F9VW0PYAKVVDY
variant_01KSCR9EBCN34947HRNE0YX51J	optval_01KSCR9EAATZB8J567B1H5ZYGN
variant_01KSCR9EBCN34947HRNE0YX51J	optval_01KSCR9EAAWS50R4TEENNCTFAS
variant_01KSCR9EBCE6BWGPAF65WMKV0A	optval_01KSCR9EABBJ0ZMZNVEPWTF0KA
variant_01KSCR9EBCNMMZ5Y3Q1Y4JDWPF	optval_01KSCR9EABJTFJXVY9FBVBVM72
variant_01KSCR9EBCXS1X5N5HFAWFFBF4	optval_01KSCR9EABFHXT4GRVC6ZR7F02
variant_01KSCR9EBCMJZVF6QQHWN7X7WQ	optval_01KSCR9EAB3JHYAGPA96BS0C5G
variant_01KSCR9EBC6H04N5PNKAG5YYAA	optval_01KSCR9EAB0C7E9QMMHGSZN1G9
variant_01KSCR9EBCYVV229KF5B1DHB0P	optval_01KSCR9EABZEG2HF1QAWNSK5PC
variant_01KSCR9EBCPQ162CT8P8JYJ208	optval_01KSCR9EABRHB3DHD62JRXM3K0
variant_01KSCR9EBC6292NXWNKFT12BMR	optval_01KSCR9EABGQ4GH89MQMET732Z
variant_01KSCR9EBD5ARPWGHVT9C1YYH2	optval_01KSCR9EACHJWB3TAV05R5VWBJ
variant_01KSCR9EBD48FCYXEHZ28PQTG1	optval_01KSCR9EAC5VGGMXNZCFEXRZJA
variant_01KSCR9EBDR67KBGB0BSV76Z1Q	optval_01KSCR9EACVC08S2V3ZWHG363Y
variant_01KSCR9EBDQEQRFWFY9KZ76VHQ	optval_01KSCR9EACZ94YZWJD13MWH763
variant_01KSDEEB4X5XQS5EZAMWG8KH96	optval_01KSDEEB3ZSF95TTX0KBVP1JZX
variant_01KSDEEB4Y5FRC1M9K6A8SS7E4	optval_01KSDEEB3ZWTVTJ6HZDNAXV560
variant_01KSH2A902V793W1CP9H7Y6ZMT	optval_01KSH2A8YQP63W3VS4MN0QDV67
variant_01KT156V1Q6CDQTENG754WVA87	optval_01KT156V00PJGMP7FTP4V3D740
variant_01KT156V1Q6CDQTENG754WVA87	optval_01KT156V01SKS0VC1DFFQ624AG
variant_01KT156V1QEBNZXXPH2KM55161	optval_01KT156V00PJGMP7FTP4V3D740
variant_01KT156V1QEBNZXXPH2KM55161	optval_01KT156V01XJKV1HPDJRCR35G4
variant_01KT156V1QZZFWVV6M8QH9QATX	optval_01KT156V00PJGMP7FTP4V3D740
variant_01KT156V1QZZFWVV6M8QH9QATX	optval_01KT156V01MFKQMDE01AX72KN2
variant_01KT156V1RSWV24EF942MK1XM1	optval_01KT156V00PJGMP7FTP4V3D740
variant_01KT156V1RSWV24EF942MK1XM1	optval_01KT156V01D8KG0168DC8FR8PP
variant_01KT156V1RDGKYWHTKBZ5AEPKA	optval_01KT156V00ECWD6RR95E6FNR4C
variant_01KT156V1RDGKYWHTKBZ5AEPKA	optval_01KT156V01SKS0VC1DFFQ624AG
variant_01KT156V1RTTF8ZFM532ZHY478	optval_01KT156V00ECWD6RR95E6FNR4C
variant_01KT156V1RTTF8ZFM532ZHY478	optval_01KT156V01XJKV1HPDJRCR35G4
variant_01KT156V1R0W7QGY9RZ0AFW25G	optval_01KT156V00ECWD6RR95E6FNR4C
variant_01KT156V1R0W7QGY9RZ0AFW25G	optval_01KT156V01MFKQMDE01AX72KN2
variant_01KT156V1R33TNWGM1H7YV0QK8	optval_01KT156V00ECWD6RR95E6FNR4C
variant_01KT156V1R33TNWGM1H7YV0QK8	optval_01KT156V01D8KG0168DC8FR8PP
variant_01KT156V1R89CA2Y8H3AH9YV1B	optval_01KT156V00V76KZAMB33A8GGAX
variant_01KT156V1R89CA2Y8H3AH9YV1B	optval_01KT156V01SKS0VC1DFFQ624AG
variant_01KT156V1RRDQ96ZYAC7T058WN	optval_01KT156V00V76KZAMB33A8GGAX
variant_01KT156V1RRDQ96ZYAC7T058WN	optval_01KT156V01XJKV1HPDJRCR35G4
variant_01KT156V1SD23PGB9TGKF13SWS	optval_01KT156V00V76KZAMB33A8GGAX
variant_01KT156V1SD23PGB9TGKF13SWS	optval_01KT156V01MFKQMDE01AX72KN2
variant_01KT156V1S9VHZR8HT8193DZ8Z	optval_01KT156V00V76KZAMB33A8GGAX
variant_01KT156V1S9VHZR8HT8193DZ8Z	optval_01KT156V01D8KG0168DC8FR8PP
variant_01KTJ4E452HDB1ARE48S9FRW6B	optval_01KTJ4E43QDHAJYWVAM2E66T4C
variant_01KTJ4K78R58KXSVS5BHXX5F4Y	optval_01KTJ4K77E9GY2DTQ73B6ES0YB
variant_01KV5D7S7XGAA4YZSHQ0ACR1DZ	optval_01KV5D7S5BT57VWT9GRZEGZKSA
variant_01KV5D7S7XPY4RGQ25F30C8SFN	optval_01KV5D7S5BBDDJ2XAQDCKR8GX4
variant_01KV5D7S7Y5BPNZK7FRBTSZKQW	optval_01KV5D7S5BAEE8Q4KQV2TNC92P
variant_01KV5DPWSCN3T6MAJ0GYN5HP8H	optval_01KV5DPWQNW0RRH5J81S249ZRR
variant_01KV5DWPP9MHKVNJ2J9TVRHFQF	optval_01KV5DWPN1N2XTY6EN59AJSJFH
variant_01KV5E602RNH70N1K2VTF7GA0D	optval_01KV5E60120YAVQB0FEW8QHTGN
variant_01KV5H8J2SS3M2Q24QZY9N1146	optval_01KV5H8J0Y0FY0VEP8DVM7M98H
variant_01KV5K1Y7YYFQVWGAWEBNRGXB9	optval_01KV5K1Y66376RNGFACBCFA06Y
variant_01KV5K1Y7Y8GVH4HFJ28G7C2ST	optval_01KV5K1Y66GW1H3Z93692JW9WE
variant_01KV5K1Y7ZB131EVPGZ9M407MM	optval_01KV5K1Y6629FDYX15Q2EPXV4N
variant_01KVAHVT2EBVYQBAVTR9ZSV73R	optval_01KVAHVT11RXBH5WDYED6VV177
variant_01KVAHVT2EBVYQBAVTR9ZSV73R	optval_01KVAHVT12XKJ2VAKQ68WWKBR9
variant_01KVAHVT2EKW039PVGG0YMCKJ1	optval_01KVAHVT11RXBH5WDYED6VV177
variant_01KVAHVT2EKW039PVGG0YMCKJ1	optval_01KVAHVT12NGPP5EGPRA63N9ZP
variant_01KVAHVT2EFGQC5VJRK8VZ2D16	optval_01KVAHVT11RXBH5WDYED6VV177
variant_01KVAHVT2EFGQC5VJRK8VZ2D16	optval_01KVAHVT12QMENVMP1JGGV61PJ
variant_01KVAHVT2EC2B5PDWT67B8XB71	optval_01KVAHVT113HKKX10XWDDXHQY9
variant_01KVAHVT2EC2B5PDWT67B8XB71	optval_01KVAHVT12XKJ2VAKQ68WWKBR9
variant_01KVAHVT2EP90KV9WDPRH9JG0C	optval_01KVAHVT113HKKX10XWDDXHQY9
variant_01KVAHVT2EP90KV9WDPRH9JG0C	optval_01KVAHVT12NGPP5EGPRA63N9ZP
variant_01KVAHVT2F88YAB61SD8RNZ35Z	optval_01KVAHVT113HKKX10XWDDXHQY9
variant_01KVAHVT2F88YAB61SD8RNZ35Z	optval_01KVAHVT12QMENVMP1JGGV61PJ
variant_01KVAHVT2F55NN49QV71ND47S1	optval_01KVAHVT119RKE73QNR93H0C2F
variant_01KVAHVT2F55NN49QV71ND47S1	optval_01KVAHVT12XKJ2VAKQ68WWKBR9
variant_01KVAHVT2FM2YBRCS7RT6W7JDQ	optval_01KVAHVT119RKE73QNR93H0C2F
variant_01KVAHVT2FM2YBRCS7RT6W7JDQ	optval_01KVAHVT12NGPP5EGPRA63N9ZP
variant_01KVAHVT2FG61XFHY82W48YTQB	optval_01KVAHVT119RKE73QNR93H0C2F
variant_01KVAHVT2FG61XFHY82W48YTQB	optval_01KVAHVT12QMENVMP1JGGV61PJ
variant_01KVAHVT2F8CPCVV47YJ2SGPJG	optval_01KVAHVT118HCSPH384FYSWFYN
variant_01KVAHVT2F8CPCVV47YJ2SGPJG	optval_01KVAHVT12XKJ2VAKQ68WWKBR9
variant_01KVAHVT2F31911T068HKBAC4T	optval_01KVAHVT118HCSPH384FYSWFYN
variant_01KVAHVT2F31911T068HKBAC4T	optval_01KVAHVT12NGPP5EGPRA63N9ZP
variant_01KVAHVT2G0Z84AKT0PB02B7WB	optval_01KVAHVT118HCSPH384FYSWFYN
variant_01KVAHVT2G0Z84AKT0PB02B7WB	optval_01KVAHVT12QMENVMP1JGGV61PJ
variant_01KVAHVT2GP4TRP54275NTZTNN	optval_01KVAHVT12VDJ4E81NHX627XAA
variant_01KVAHVT2GP4TRP54275NTZTNN	optval_01KVAHVT12XKJ2VAKQ68WWKBR9
variant_01KVAHVT2GAH734RVEBJFDYTW5	optval_01KVAHVT12VDJ4E81NHX627XAA
variant_01KVAHVT2GAH734RVEBJFDYTW5	optval_01KVAHVT12NGPP5EGPRA63N9ZP
variant_01KVAHVT2GZ68V2K3DP2W36T40	optval_01KVAHVT12VDJ4E81NHX627XAA
variant_01KVAHVT2GZ68V2K3DP2W36T40	optval_01KVAHVT12QMENVMP1JGGV61PJ
variant_01KVAHVT2GG8P6AH8R8HFEZH0E	optval_01KVAHVT12F4VGWVYCN744WFAX
variant_01KVAHVT2GG8P6AH8R8HFEZH0E	optval_01KVAHVT12XKJ2VAKQ68WWKBR9
variant_01KVAHVT2GQ7RSYTG6CVBR86D7	optval_01KVAHVT12F4VGWVYCN744WFAX
variant_01KVAHVT2GQ7RSYTG6CVBR86D7	optval_01KVAHVT12NGPP5EGPRA63N9ZP
variant_01KVAHVT2G8EYFH7877KZ9P609	optval_01KVAHVT12F4VGWVYCN744WFAX
variant_01KVAHVT2G8EYFH7877KZ9P609	optval_01KVAHVT12QMENVMP1JGGV61PJ
variant_01KVAHVT2GSFK731WQE0KHHMD7	optval_01KVAHVT127ATD5WJ24A61MH31
variant_01KVAHVT2GSFK731WQE0KHHMD7	optval_01KVAHVT12XKJ2VAKQ68WWKBR9
variant_01KVAHVT2JSBEBNQN7AQ4HWWV8	optval_01KVAHVT127ATD5WJ24A61MH31
variant_01KVAHVT2JSBEBNQN7AQ4HWWV8	optval_01KVAHVT12NGPP5EGPRA63N9ZP
variant_01KVAHVT2JVPEVJA8HAW31CY3R	optval_01KVAHVT127ATD5WJ24A61MH31
variant_01KVAHVT2JVPEVJA8HAW31CY3R	optval_01KVAHVT12QMENVMP1JGGV61PJ
variant_01KVANBHZT17X97GMN7H90KG4H	optval_01KVANBHYW8Y2QHGCQDQWNTSK6
variant_01KWT4YC08GHVNG1VSZDQVEJ4K	optval_01KWT4YBXBP310M3DEBHDRMY6B
variant_01KWT4YC09506GRNFD29SZ1RFP	optval_01KWT4YBXB2FXQWEZ5J38MVTRJ
variant_01KWT4YC09NXR46MJEBHPSV5F3	optval_01KWT4YBXBBTVB51Q7VXFXBQN5
variant_01KWT4YC09SDR7B73TQTD3N1AF	optval_01KWT4YBXCA22NR1AJWM5VNQWZ
variant_01KWT4YC0ADA44FBSQ409TSB9C	optval_01KWT4YBXCQZ4J99VWNNVBY551
variant_01KWTKZBP0CNV7C3N5X7799R31	optval_01KWTKZBN121HFGWM46W8D7Z5H
variant_01KWTKZBP0T469V7GSXHBYCA06	optval_01KWTKZBN1BC2NN74PS7H2VSHQ
variant_01KWTKZBP0ZM5SKYT8FF8TRK05	optval_01KWTKZBN1AT0TXECSGGFRNZNH
\.


--
-- Data for Name: product_variant_price_set; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_variant_price_set (variant_id, price_set_id, id, created_at, updated_at, deleted_at) FROM stdin;
variant_01KSCR9EBB5SDB79TPFJJ35HPP	pset_01KSCR9ECHE40GY2K2Z5RKJPRB	pvps_01KSCR9ED72EMV1G2EZDXH0XEK	2026-05-24 12:25:31.04763+02	2026-05-24 12:25:31.04763+02	\N
variant_01KSCR9EBCY91XPNSCP8NXT8F2	pset_01KSCR9ECHJZD63PJ02VHCNE2C	pvps_01KSCR9ED8XVGCM2V96Q0SRGJ6	2026-05-24 12:25:31.04763+02	2026-05-24 12:25:31.04763+02	\N
variant_01KSCR9EBC52MBRCSV877TQXP5	pset_01KSCR9ECHAE8KQBHZ663MV2PJ	pvps_01KSCR9ED81FPF4Q8QFVKYTB9E	2026-05-24 12:25:31.04763+02	2026-05-24 12:25:31.04763+02	\N
variant_01KSCR9EBC5YZVT1MZ87Z9R80B	pset_01KSCR9ECHXG21SJRGHCHR5G6W	pvps_01KSCR9ED8P9ERG861S6YCY9XC	2026-05-24 12:25:31.04763+02	2026-05-24 12:25:31.04763+02	\N
variant_01KSCR9EBCRNX20J9HW4HNEJ8H	pset_01KSCR9ECH59RXB1EYQD7C92QR	pvps_01KSCR9ED8A37S76ZW4P6P6JBK	2026-05-24 12:25:31.04763+02	2026-05-24 12:25:31.04763+02	\N
variant_01KSCR9EBCTFGSPR2Y2E5TN1FE	pset_01KSCR9ECH0WA5W8B6HBTATXXS	pvps_01KSCR9ED83MKDVD2MT568J7PK	2026-05-24 12:25:31.04763+02	2026-05-24 12:25:31.04763+02	\N
variant_01KSCR9EBC5APY2TXMQGMBGJJR	pset_01KSCR9ECHG3AQVY3E7N1JYSPK	pvps_01KSCR9ED86V6ZR818DTBEHE5S	2026-05-24 12:25:31.04763+02	2026-05-24 12:25:31.04763+02	\N
variant_01KSCR9EBCN34947HRNE0YX51J	pset_01KSCR9ECJD3F4M0ATYW79596N	pvps_01KSCR9ED9WN059FM7MK3M42M8	2026-05-24 12:25:31.04763+02	2026-05-24 12:25:31.04763+02	\N
variant_01KSCR9EBCE6BWGPAF65WMKV0A	pset_01KSCR9ECJ24G1ANC2YGZ4T2VP	pvps_01KSCR9ED9S4B4DMDMXG96TDVA	2026-05-24 12:25:31.04763+02	2026-05-24 12:25:31.04763+02	\N
variant_01KSCR9EBCNMMZ5Y3Q1Y4JDWPF	pset_01KSCR9ECJD177T8XAPQWQFPYA	pvps_01KSCR9ED96F5D526XASQ9BY2W	2026-05-24 12:25:31.04763+02	2026-05-24 12:25:31.04763+02	\N
variant_01KSCR9EBCXS1X5N5HFAWFFBF4	pset_01KSCR9ECJ1YF8H2NHK8JST4SC	pvps_01KSCR9ED9FYBPPN72RHZ6BSTB	2026-05-24 12:25:31.04763+02	2026-05-24 12:25:31.04763+02	\N
variant_01KSCR9EBCMJZVF6QQHWN7X7WQ	pset_01KSCR9ECJXJ0V6RMB5B6DY6CQ	pvps_01KSCR9ED9K6W5PX7P6RDZBEKE	2026-05-24 12:25:31.04763+02	2026-05-24 12:25:31.04763+02	\N
variant_01KSCR9EBC6H04N5PNKAG5YYAA	pset_01KSCR9ECJNKJHQ3GEK4BKBWTV	pvps_01KSCR9ED94YJV3FDDJ70KPCWD	2026-05-24 12:25:31.04763+02	2026-05-24 12:25:31.04763+02	\N
variant_01KSCR9EBCYVV229KF5B1DHB0P	pset_01KSCR9ECJ1GZ29MKTKB6Y4N8P	pvps_01KSCR9ED9G7HZYAHCPS2AVGZB	2026-05-24 12:25:31.04763+02	2026-05-24 12:25:31.04763+02	\N
variant_01KSCR9EBCPQ162CT8P8JYJ208	pset_01KSCR9ECJ0JGFPNPMPC6NG8N2	pvps_01KSCR9ED9EZPHNBTDPTP66ASJ	2026-05-24 12:25:31.04763+02	2026-05-24 12:25:31.04763+02	\N
variant_01KSCR9EBC6292NXWNKFT12BMR	pset_01KSCR9ECJ1RY8AB7QRXEEHW56	pvps_01KSCR9ED96CGSESRAM6QARRAX	2026-05-24 12:25:31.04763+02	2026-05-24 12:25:31.04763+02	\N
variant_01KSCR9EBD5ARPWGHVT9C1YYH2	pset_01KSCR9ECJEZEHBK43XZZQ5VSW	pvps_01KSCR9ED9X21NE5RHHJ8W3PAW	2026-05-24 12:25:31.04763+02	2026-05-24 12:25:31.04763+02	\N
variant_01KSCR9EBD48FCYXEHZ28PQTG1	pset_01KSCR9ECKQ26RMJM2G8KSW22X	pvps_01KSCR9ED98KK6K56A35YRRFYV	2026-05-24 12:25:31.04763+02	2026-05-24 12:25:31.04763+02	\N
variant_01KSCR9EBDR67KBGB0BSV76Z1Q	pset_01KSCR9ECKWY6XV6NFT0PXZHS3	pvps_01KSCR9ED9H0H9WYKDWDZVHP76	2026-05-24 12:25:31.04763+02	2026-05-24 12:25:31.04763+02	\N
variant_01KSCR9EBDQEQRFWFY9KZ76VHQ	pset_01KSCR9ECKT191MKK8JV695GZM	pvps_01KSCR9EDA18GMDVXZ4PZBW3GY	2026-05-24 12:25:31.04763+02	2026-05-24 12:25:31.04763+02	\N
variant_01KSDEEB4X5XQS5EZAMWG8KH96	pset_01KSDEEB5GG42PTYFK4AVTZ6R1	pvps_01KSDEEB5YG2T75MZAZQ6WNKWK	2026-05-24 18:52:40.254015+02	2026-05-24 18:52:40.254015+02	\N
variant_01KSDEEB4Y5FRC1M9K6A8SS7E4	pset_01KSDEEB5HM8D6TN7EBYJHBRZ4	pvps_01KSDEEB5Y9E63B9CTQRZGAB3S	2026-05-24 18:52:40.254015+02	2026-05-24 18:52:40.254015+02	\N
variant_01KSH2A902V793W1CP9H7Y6ZMT	pset_01KSH2A90QGA5K2VSPJ7S60MDE	pvps_01KSH2A917P38FP3SMTGKMXJ40	2026-05-26 04:37:41.799546+02	2026-05-26 04:37:41.799546+02	\N
variant_01KT156V1Q6CDQTENG754WVA87	pset_01KT156V3VBFXRVV4Q11J8X3XT	pvps_01KT156V5AXNKG2XEXTN5SBYGN	2026-06-01 10:36:05.929719+02	2026-06-01 10:36:05.929719+02	\N
variant_01KT156V1QEBNZXXPH2KM55161	pset_01KT156V3VSWX8PMXA8DKS19M8	pvps_01KT156V5AVY38W3ZE2JDSB62Y	2026-06-01 10:36:05.929719+02	2026-06-01 10:36:05.929719+02	\N
variant_01KT156V1QZZFWVV6M8QH9QATX	pset_01KT156V3VMAZHWFFK682434N8	pvps_01KT156V5AV5K3AWR53K4S8CY6	2026-06-01 10:36:05.929719+02	2026-06-01 10:36:05.929719+02	\N
variant_01KT156V1RSWV24EF942MK1XM1	pset_01KT156V3WNZEM2ZPB9FZXE16S	pvps_01KT156V5B1SE6VSP59V5BZWD0	2026-06-01 10:36:05.929719+02	2026-06-01 10:36:05.929719+02	\N
variant_01KT156V1RDGKYWHTKBZ5AEPKA	pset_01KT156V3WTFAP7TW72AJS9F1E	pvps_01KT156V5B866NCM3SVM2RK096	2026-06-01 10:36:05.929719+02	2026-06-01 10:36:05.929719+02	\N
variant_01KT156V1RTTF8ZFM532ZHY478	pset_01KT156V3WN800MMRWMSF4T0P4	pvps_01KT156V5B34YF0H5M4VGVMJE6	2026-06-01 10:36:05.929719+02	2026-06-01 10:36:05.929719+02	\N
variant_01KT156V1R0W7QGY9RZ0AFW25G	pset_01KT156V3W3NDDMBH6632Q7VTP	pvps_01KT156V5BQEY6PX6S9XMHJAMK	2026-06-01 10:36:05.929719+02	2026-06-01 10:36:05.929719+02	\N
variant_01KT156V1R33TNWGM1H7YV0QK8	pset_01KT156V3X95FXBAB3JK6R7ABP	pvps_01KT156V5BKJH7WZSQ7EXJ1MHS	2026-06-01 10:36:05.929719+02	2026-06-01 10:36:05.929719+02	\N
variant_01KT156V1R89CA2Y8H3AH9YV1B	pset_01KT156V3XYYTVNR9BPWDBVWBZ	pvps_01KT156V5B5ZJP5GPP1H9MJYJ7	2026-06-01 10:36:05.929719+02	2026-06-01 10:36:05.929719+02	\N
variant_01KT156V1RRDQ96ZYAC7T058WN	pset_01KT156V3XH2B3BKB2N0TPT7A6	pvps_01KT156V5CEY7CT6P6GKT4TJFS	2026-06-01 10:36:05.929719+02	2026-06-01 10:36:05.929719+02	\N
variant_01KT156V1SD23PGB9TGKF13SWS	pset_01KT156V3Y47SA55KHGT9M8VHH	pvps_01KT156V5C16P0H9GW9Z78G3VS	2026-06-01 10:36:05.929719+02	2026-06-01 10:36:05.929719+02	\N
variant_01KT156V1S9VHZR8HT8193DZ8Z	pset_01KT156V3YHWKTQ5Z5GZWS37Q1	pvps_01KT156V5C63KH9W32X883XZPQ	2026-06-01 10:36:05.929719+02	2026-06-01 10:36:05.929719+02	\N
variant_01KTJ4E452HDB1ARE48S9FRW6B	pset_01KTJ4E45RW880A8MYSVFTT8DD	pvps_01KTJ4E46A15WMQD9Y47WBGQYN	2026-06-08 00:49:41.32254+02	2026-06-08 00:52:07.287+02	2026-06-08 00:52:07.286+02
variant_01KTJ4K78R58KXSVS5BHXX5F4Y	pset_01KTJ4K798SP2PAF6PCAAXKW87	pvps_01KTJ4K79MN5Z6M5F5ZVF30CSW	2026-06-08 00:52:28.340069+02	2026-06-08 01:10:45.814+02	2026-06-08 01:10:45.813+02
variant_01KV5D7S7XGAA4YZSHQ0ACR1DZ	pset_01KV5D7S9TYTC7SFWVRVZEGQB0	pvps_01KV5D7SB0E9MRAZ1XNEATFFFT	2026-06-15 12:29:04.99185+02	2026-06-15 12:29:04.99185+02	\N
variant_01KV5D7S7XPY4RGQ25F30C8SFN	pset_01KV5D7S9TP10800TW3WHQ04C8	pvps_01KV5D7SB08DNHCWW6FBDQRA15	2026-06-15 12:29:04.99185+02	2026-06-15 12:29:04.99185+02	\N
variant_01KV5D7S7Y5BPNZK7FRBTSZKQW	pset_01KV5D7S9TR19AN3QVC7ET7214	pvps_01KV5D7SB1V7Q0NRP8H6DXN8FK	2026-06-15 12:29:04.99185+02	2026-06-15 12:29:04.99185+02	\N
variant_01KV5DPWSCN3T6MAJ0GYN5HP8H	pset_01KV5DPWT3ZY8C326065RTM590	pvps_01KV5DPWTE0AKVNXZ21FCEH2QY	2026-06-15 12:37:20.077935+02	2026-06-15 12:37:20.077935+02	\N
variant_01KV5DWPP9MHKVNJ2J9TVRHFQF	pset_01KV5DWPQ5KDEYENVPDVFDEHHR	pvps_01KV5DWPQKERXAG52CNXS4GAT6	2026-06-15 12:40:30.451531+02	2026-06-15 12:40:30.451531+02	\N
variant_01KV5E602RNH70N1K2VTF7GA0D	pset_01KV5E6041R9MBH4H2CRAB8SQS	pvps_01KV5E604GEBTFHB8610T9DJ99	2026-06-15 12:45:34.99266+02	2026-06-15 12:45:34.99266+02	\N
variant_01KV5H8J2SS3M2Q24QZY9N1146	pset_01KV5H8J3V85VMD43NPCT6A2WV	pvps_01KV5H8J49V90BM037VM0HXKXJ	2026-06-15 13:39:24.680825+02	2026-06-15 13:39:24.680825+02	\N
variant_01KV5K1Y7YYFQVWGAWEBNRGXB9	pset_01KV5K1Y9492N8RY3JNHW4BXC6	pvps_01KV5K1Y9ZE9N1RAWH6PC7MKYD	2026-06-15 14:10:44.926771+02	2026-06-15 14:10:44.926771+02	\N
variant_01KV5K1Y7Y8GVH4HFJ28G7C2ST	pset_01KV5K1Y956GPMCRPABP7AV8RY	pvps_01KV5K1YA0ZFKGDAKN9JGMJ8YT	2026-06-15 14:10:44.926771+02	2026-06-15 14:10:44.926771+02	\N
variant_01KV5K1Y7ZB131EVPGZ9M407MM	pset_01KV5K1Y95KXR5B4TNKZGQAEM5	pvps_01KV5K1YA0YCW6F8F94GAE8A8M	2026-06-15 14:10:44.926771+02	2026-06-15 14:10:44.926771+02	\N
variant_01KVAHVT2EBVYQBAVTR9ZSV73R	pset_01KVAHVT45RD93ZFMXY8C2WFFX	pvps_01KVAHVT552VDN6BWCQ5380MP0	2026-06-17 12:26:07.653813+02	2026-06-17 12:26:07.653813+02	\N
variant_01KVAHVT2EKW039PVGG0YMCKJ1	pset_01KVAHVT46VN53S8BNKGM7QZBC	pvps_01KVAHVT568GTYRXXYW1S10NCP	2026-06-17 12:26:07.653813+02	2026-06-17 12:26:07.653813+02	\N
variant_01KVAHVT2EFGQC5VJRK8VZ2D16	pset_01KVAHVT4608T1016E8V0EY3M1	pvps_01KVAHVT564J82H1JHZPHQGGZX	2026-06-17 12:26:07.653813+02	2026-06-17 12:26:07.653813+02	\N
variant_01KVAHVT2EC2B5PDWT67B8XB71	pset_01KVAHVT46FY9ZRB1CV6JZAF1Y	pvps_01KVAHVT56596EFDB3XBTKPEBA	2026-06-17 12:26:07.653813+02	2026-06-17 12:26:07.653813+02	\N
variant_01KVAHVT2EP90KV9WDPRH9JG0C	pset_01KVAHVT46AVPYKBJCAB32Q2ZT	pvps_01KVAHVT56BRB47530BF847JXR	2026-06-17 12:26:07.653813+02	2026-06-17 12:26:07.653813+02	\N
variant_01KVAHVT2F88YAB61SD8RNZ35Z	pset_01KVAHVT47ABW1HSCBQYDP833B	pvps_01KVAHVT564H3XN6RH5466KT79	2026-06-17 12:26:07.653813+02	2026-06-17 12:26:07.653813+02	\N
variant_01KVAHVT2F55NN49QV71ND47S1	pset_01KVAHVT47M0QVSR1EVWHEW1MM	pvps_01KVAHVT56PES95CWRKZZGKM3G	2026-06-17 12:26:07.653813+02	2026-06-17 12:26:07.653813+02	\N
variant_01KVAHVT2FM2YBRCS7RT6W7JDQ	pset_01KVAHVT4726BH46J4SDJ20KKA	pvps_01KVAHVT56Y6WJXCAB3RS7Y0MD	2026-06-17 12:26:07.653813+02	2026-06-17 12:26:07.653813+02	\N
variant_01KVAHVT2FG61XFHY82W48YTQB	pset_01KVAHVT47X01EWBZWJVY3C7MZ	pvps_01KVAHVT56Z7K74XYXRH9A1TAQ	2026-06-17 12:26:07.653813+02	2026-06-17 12:26:07.653813+02	\N
variant_01KVAHVT2F8CPCVV47YJ2SGPJG	pset_01KVAHVT4747ADVFQ1E0HFE763	pvps_01KVAHVT566W7B2QRX6R56DAYC	2026-06-17 12:26:07.653813+02	2026-06-17 12:26:07.653813+02	\N
variant_01KVAHVT2F31911T068HKBAC4T	pset_01KVAHVT486V8XNKGAXQF1GTH1	pvps_01KVAHVT56SJQS94A63R5CDGQC	2026-06-17 12:26:07.653813+02	2026-06-17 12:26:07.653813+02	\N
variant_01KVAHVT2G0Z84AKT0PB02B7WB	pset_01KVAHVT48DT5PNG1Q87K5BZ25	pvps_01KVAHVT56J9YTJMK4QWNW7SH4	2026-06-17 12:26:07.653813+02	2026-06-17 12:26:07.653813+02	\N
variant_01KVAHVT2GP4TRP54275NTZTNN	pset_01KVAHVT488QNH6K8DWXBVK5N4	pvps_01KVAHVT56MV786A0CTZA32DS8	2026-06-17 12:26:07.653813+02	2026-06-17 12:26:07.653813+02	\N
variant_01KVAHVT2GAH734RVEBJFDYTW5	pset_01KVAHVT48AT7Q7M9K2563NZ1R	pvps_01KVAHVT562N6Y0ZJ0VV10FZYE	2026-06-17 12:26:07.653813+02	2026-06-17 12:26:07.653813+02	\N
variant_01KVAHVT2GZ68V2K3DP2W36T40	pset_01KVAHVT49BNGM03CV3QQJFNPN	pvps_01KVAHVT56HMGSD0BWWZKKDHK5	2026-06-17 12:26:07.653813+02	2026-06-17 12:26:07.653813+02	\N
variant_01KVAHVT2GG8P6AH8R8HFEZH0E	pset_01KVAHVT4937W3EPX99YE0MSQT	pvps_01KVAHVT56P87G0FRGZZ338D9G	2026-06-17 12:26:07.653813+02	2026-06-17 12:26:07.653813+02	\N
variant_01KVAHVT2GQ7RSYTG6CVBR86D7	pset_01KVAHVT49SHP034ZQ3Y63V10X	pvps_01KVAHVT56E5HS5N5B9S6KRZ4H	2026-06-17 12:26:07.653813+02	2026-06-17 12:26:07.653813+02	\N
variant_01KVAHVT2G8EYFH7877KZ9P609	pset_01KVAHVT497DGKT7D3S61C8042	pvps_01KVAHVT56H6V2M5B82D8RH4PJ	2026-06-17 12:26:07.653813+02	2026-06-17 12:26:07.653813+02	\N
variant_01KVAHVT2GSFK731WQE0KHHMD7	pset_01KVAHVT4A57TBKSHPF9JYNKG6	pvps_01KVAHVT56AT6CW856FW3K8V4G	2026-06-17 12:26:07.653813+02	2026-06-17 12:26:07.653813+02	\N
variant_01KVAHVT2JSBEBNQN7AQ4HWWV8	pset_01KVAHVT4AQ1X70YK8PESJ5EMG	pvps_01KVAHVT56RF09E0EVCAMCAX60	2026-06-17 12:26:07.653813+02	2026-06-17 12:26:07.653813+02	\N
variant_01KVAHVT2JVPEVJA8HAW31CY3R	pset_01KVAHVT4ATEHMPJ0904F0MY23	pvps_01KVAHVT565ZHCZY199Z4X3XSE	2026-06-17 12:26:07.653813+02	2026-06-17 12:26:07.653813+02	\N
variant_01KVANBHZT17X97GMN7H90KG4H	pset_01KVANBJ09PZRD5ZM52KW8DW8J	pvps_01KVANBJ0K97AJF009ZYNZ2ECF	2026-06-17 13:27:09.331495+02	2026-06-17 13:27:09.331495+02	\N
variant_01KWT4YC08GHVNG1VSZDQVEJ4K	pset_01KWT4YC2P3KA9BH80NS3SBC5K	pvps_01KWT4YC45X76HPQJBVS0F2QJX	2026-07-06 00:03:52.836835+02	2026-07-06 04:22:16.263+02	2026-07-06 04:22:16.262+02
variant_01KWT4YC09506GRNFD29SZ1RFP	pset_01KWT4YC2QP3SC4RFPX6CPF4DS	pvps_01KWT4YC45Z8MTXTY6FF2D6A35	2026-07-06 00:03:52.836835+02	2026-07-06 04:22:16.263+02	2026-07-06 04:22:16.262+02
variant_01KWT4YC09NXR46MJEBHPSV5F3	pset_01KWT4YC2QGXJX6T5SWV243PAH	pvps_01KWT4YC46YETCZN5QRW2AXTT9	2026-07-06 00:03:52.836835+02	2026-07-06 04:22:16.263+02	2026-07-06 04:22:16.262+02
variant_01KWT4YC09SDR7B73TQTD3N1AF	pset_01KWT4YC2R9PPR5X1FZW7GRVJ4	pvps_01KWT4YC4652RQTBEC6Q3RXQV4	2026-07-06 00:03:52.836835+02	2026-07-06 04:22:16.263+02	2026-07-06 04:22:16.262+02
variant_01KWT4YC0ADA44FBSQ409TSB9C	pset_01KWT4YC2R1NJT7B46YXPZ3Y7B	pvps_01KWT4YC46S807T63PXC3HQYJF	2026-07-06 00:03:52.836835+02	2026-07-06 04:22:16.263+02	2026-07-06 04:22:16.262+02
variant_01KWTKZBP0CNV7C3N5X7799R31	pset_01KWTKZBPN5HPVGKXTQXEEG2Q3	pvps_01KWTKZBPWANHVMYDEGGV95QXP	2026-07-06 04:26:33.820658+02	2026-07-06 04:26:33.820658+02	\N
variant_01KWTKZBP0T469V7GSXHBYCA06	pset_01KWTKZBPNPY6S1ZFFZK6NXSTR	pvps_01KWTKZBPW00GQ1GMNJBJSM4BG	2026-07-06 04:26:33.820658+02	2026-07-06 04:26:33.820658+02	\N
variant_01KWTKZBP0ZM5SKYT8FF8TRK05	pset_01KWTKZBPN656VNSKCY67QZ69K	pvps_01KWTKZBPWTG7331RPDY3G12AB	2026-07-06 04:26:33.820658+02	2026-07-06 04:26:33.820658+02	\N
\.


--
-- Data for Name: product_variant_product_image; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_variant_product_image (id, variant_id, image_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: promotion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promotion (id, code, campaign_id, is_automatic, type, created_at, updated_at, deleted_at, status, is_tax_inclusive, "limit", used, metadata) FROM stdin;
promo_01KSFTYA07BW0AWQY1MGK5YPZ2	JJJJJJJK	\N	f	standard	2026-05-25 17:09:35.116+02	2026-05-25 17:25:35.113+02	2026-05-25 17:25:35.11+02	draft	f	\N	0	\N
promo_01KSSPF5WN97JJ7DAEWAWW9TQJ	YGO	\N	f	standard	2026-05-29 13:03:49.398+02	2026-05-29 13:03:49.398+02	\N	draft	f	\N	0	\N
promo_01KZSMC1MKPKD3FQJ759MBCX6D	EM-M1ERBFUG	\N	f	standard	2026-08-12 02:01:20.532+02	2026-08-12 02:01:20.532+02	\N	draft	f	\N	0	\N
promo_01KZSMEY4VRFZ2AXHA9GMJZBTC	EM-O9X2TFZJ	\N	f	standard	2026-08-12 02:02:55.262+02	2026-08-12 02:02:55.262+02	\N	active	f	\N	0	\N
promo_01KZSNVQVHV4YR8R403X1ZZPDG	FLASH-LP02E1	procamp_01KZSNVQTSDNCNWRT8SHENQX8C	t	standard	2026-08-12 02:27:23.381+02	2026-08-12 02:27:23.381+02	\N	active	f	\N	0	\N
promo_01KZTFBR4ESFK9JXFQ78933ASZ	EM-DV0ZJ3KZ	\N	f	standard	2026-08-12 09:53:02.354+02	2026-08-12 09:53:02.354+02	\N	active	f	\N	0	\N
promo_01KZTFBR4WP6PH32FGP5X3T8F4	EM-XRE56ZBF	\N	f	standard	2026-08-12 09:53:02.365+02	2026-08-12 09:53:02.365+02	\N	active	f	\N	0	\N
promo_01KZV29F639S64PE98E234TFXZ	FLASH-DOKP28	procamp_01KZV29F4R1GY8TJ1J0A480D8E	t	standard	2026-08-12 15:23:50.604+02	2026-08-12 15:23:50.604+02	\N	active	f	\N	0	\N
promo_01KZYEPW8TW36MNCRVNQZESW9R	EM-NMNFJW5W	\N	f	standard	2026-08-13 22:58:36.19+02	2026-08-13 22:58:36.19+02	\N	active	f	\N	0	\N
\.


--
-- Data for Name: promotion_application_method; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promotion_application_method (id, value, raw_value, max_quantity, apply_to_quantity, buy_rules_min_quantity, type, target_type, allocation, promotion_id, created_at, updated_at, deleted_at, currency_code) FROM stdin;
proappmet_01KSFTYA0A9HYX8WN5FXFPE6VX	20	{"value": "20", "precision": 20}	\N	\N	\N	percentage	items	across	promo_01KSFTYA07BW0AWQY1MGK5YPZ2	2026-05-25 17:09:35.115+02	2026-05-25 17:09:35.115+02	\N	\N
proappmet_01KSSPF5WPNHGDFXSEG1ATNVT6	20	{"value": "20", "precision": 20}	\N	\N	\N	percentage	items	across	promo_01KSSPF5WN97JJ7DAEWAWW9TQJ	2026-05-29 13:03:49.398+02	2026-05-29 13:03:49.398+02	\N	\N
proappmet_01KZSMC1MKH53VANPGG25ABB90	5	{"value": "5", "precision": 20}	\N	\N	\N	percentage	items	across	promo_01KZSMC1MKPKD3FQJ759MBCX6D	2026-08-12 02:01:20.531+02	2026-08-12 02:01:20.531+02	\N	\N
proappmet_01KZSMEY4XD1TMAD8Q99ZFCPRN	10	{"value": "10", "precision": 20}	\N	\N	\N	percentage	items	across	promo_01KZSMEY4VRFZ2AXHA9GMJZBTC	2026-08-12 02:02:55.261+02	2026-08-12 02:02:55.261+02	\N	\N
proappmet_01KZSNVQVJBD4J6NZG0BF7QE85	20	{"value": "20", "precision": 20}	\N	\N	\N	percentage	items	across	promo_01KZSNVQVHV4YR8R403X1ZZPDG	2026-08-12 02:27:23.381+02	2026-08-12 02:27:23.381+02	\N	\N
proappmet_01KZTFBR4HADWY1ZF7HZW7RM8T	10	{"value": "10", "precision": 20}	\N	\N	\N	percentage	items	across	promo_01KZTFBR4ESFK9JXFQ78933ASZ	2026-08-12 09:53:02.353+02	2026-08-12 09:53:02.353+02	\N	\N
proappmet_01KZTFBR4WFMATANHQVFW1G2F1	10	{"value": "10", "precision": 20}	\N	\N	\N	percentage	items	across	promo_01KZTFBR4WP6PH32FGP5X3T8F4	2026-08-12 09:53:02.365+02	2026-08-12 09:53:02.365+02	\N	\N
proappmet_01KZV29F65P9N6CBXA7VTMH2GE	15	{"value": "15", "precision": 20}	\N	\N	\N	percentage	items	across	promo_01KZV29F639S64PE98E234TFXZ	2026-08-12 15:23:50.603+02	2026-08-12 15:23:50.603+02	\N	\N
proappmet_01KZYEPW8WX7AV19TFZJYYKWXC	0	{"value": "0", "precision": 20}	\N	\N	\N	fixed	shipping_methods	across	promo_01KZYEPW8TW36MNCRVNQZESW9R	2026-08-13 22:58:36.189+02	2026-08-13 22:58:36.189+02	\N	\N
\.


--
-- Data for Name: promotion_campaign; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promotion_campaign (id, name, description, campaign_identifier, starts_at, ends_at, created_at, updated_at, deleted_at) FROM stdin;
procamp_01KZSNVQTSDNCNWRT8SHENQX8C	Demo Flash Sale	\N	FLASH-BUP26N	2026-08-12 02:27:23+02	2026-08-12 04:27:23+02	2026-08-12 02:27:23.353+02	2026-08-12 02:27:23.353+02	\N
procamp_01KZV29F4R1GY8TJ1J0A480D8E	Vendor-wide sale	\N	FLASH-6ILYSV	2026-08-12 15:23:50+02	2026-08-12 17:23:50+02	2026-08-12 15:23:50.553+02	2026-08-12 15:23:50.553+02	\N
\.


--
-- Data for Name: promotion_campaign_budget; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promotion_campaign_budget (id, type, campaign_id, "limit", raw_limit, used, raw_used, created_at, updated_at, deleted_at, currency_code, attribute) FROM stdin;
\.


--
-- Data for Name: promotion_campaign_budget_usage; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promotion_campaign_budget_usage (id, attribute_value, used, budget_id, raw_used, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: promotion_promotion_rule; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promotion_promotion_rule (promotion_id, promotion_rule_id) FROM stdin;
\.


--
-- Data for Name: promotion_rule; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promotion_rule (id, description, attribute, operator, created_at, updated_at, deleted_at) FROM stdin;
prorul_01KZSNVQVMT8DYTTNA50SF2Z98	\N	items.product_id	in	2026-08-12 02:27:23.381+02	2026-08-12 02:27:23.381+02	\N
prorul_01KZV29F68FNS6X4JF1VRBFTSK	\N	items.vendor_id	eq	2026-08-12 15:23:50.602+02	2026-08-12 15:23:50.602+02	\N
\.


--
-- Data for Name: promotion_rule_value; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promotion_rule_value (id, promotion_rule_id, value, created_at, updated_at, deleted_at) FROM stdin;
prorulval_01KZSNVQVMJ8FS54KHAPCHC187	prorul_01KZSNVQVMT8DYTTNA50SF2Z98	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	2026-08-12 02:27:23.382+02	2026-08-12 02:27:23.382+02	\N
prorulval_01KZV29F69T0WB3C2Z99H5KDQK	prorul_01KZV29F68FNS6X4JF1VRBFTSK	01KZSNE0N2NMDBYY9W8KGY0GJW	2026-08-12 15:23:50.604+02	2026-08-12 15:23:50.604+02	\N
\.


--
-- Data for Name: provider_identity; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.provider_identity (id, entity_id, provider, auth_identity_id, user_metadata, provider_metadata, created_at, updated_at, deleted_at) FROM stdin;
01KSCRW56KYQWB706Q0YTAP1NY	princelulinda@gmail.com	emailpass	authid_01KSCRW56M4HHGZ62YKHD3GN8G	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAfFnv3HeVsi6KluO4kDnJc3Bdfg5OZjv2PY90VNzHivXkw071mUM6ApcmQ1t09gS40kRYwRZZGFHfTQV5aoWkZxdt9w3iwQYgJxaXaOcJW3k"}	2026-05-24 12:35:44.213+02	2026-05-24 12:35:44.213+02	\N
01KSCS5ZMFG3Q1YG9Y21B8CCVP	princelulinda12@gmail.com	emailpass	authid_01KSCS5ZMFWQ794DK9P2KTPC9H	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAfWNiB0Gj7XCGYmYRpBO5wUyiXSi4rQsGlkkBBvCMRJBgUvOfQ9+JXPy3BwxkKy3gaUSrPFjTeCyHGOCP5Wtp/5S/usFi2rFIqwzHFiBqDsJ"}	2026-05-24 12:41:06.192+02	2026-05-24 12:41:06.192+02	\N
01KSCSTEDY4A5BGZPWEGRGEDWN	princelulinda1@gmail.com	emailpass	authid_01KSCSTEDYTSQVWN8D97W0H5S6	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAYQONnkvkf/ezOmNSoN+9r6h/2BtGWMimmk1Zp/OIimf9CDs1UVMWUk0uHSIcWuQSIYJP66UwBSnsGKmFJbS8aL+Cjb6/F8iC0QwSncuM4tP"}	2026-05-24 12:52:16.702+02	2026-05-24 12:52:16.702+02	\N
01KSDE84ASP8J1XDAACJBX3470	princelulinda122@gmail.com	emailpass	authid_01KSDE84ASAVWY2BJH057MCBXY	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAdkiRH8TS9xIODA/W18aUjgpy4yvn8q/NHRVXwY2ZHSt4q9DCxmcGX01SXkzIgT+gQcwCFVy4zTiabhB1YusQU0F4Zg8dNXo/S7PB+VigNOb"}	2026-05-24 18:49:16.633+02	2026-05-24 18:49:16.633+02	\N
01KSDGJHCS65FZCDRA5GRXY05M	princelulinda+890@gmail.com	emailpass	authid_01KSDGJHCTKACVMAMDBVGKA4AN	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAQZT/PStrlD69SoA2uWBWK8N74bh3YLq+3WuxVfjmiwlnE/gnJlv7jcxsXoF/ui5Ef08IJcDcTxE18thg6qkiScNNt5XcQPU3U7KpHjTEJsj"}	2026-05-24 19:29:54.843+02	2026-05-24 19:32:35.255+02	\N
01KSQWK78GDB2DPGQAK10E4S27	princelulinda78@gmail.com	emailpass	authid_01KSQWK78GPYSWFDV5PD3K0GNQ	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAa7iTCdtKEG7aAt+hlYV6PqoxkkXWYCPymUopq04RZcjdeA2F2Vr6iC5WSFkrcoTK70xI0Pej3CoTg8ATEJ9pUz7/wCtrebyHIBhbiLfcwkq"}	2026-05-28 20:12:24.465+02	2026-05-28 20:12:50.781+02	\N
01KSR173CGKKKKCD5N70HX4AQQ	princelulinda32@gmail.com	emailpass	authid_01KSR173CHW8REA4FMY690R5MR	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAeWWJsZmV73oMqx/th8Tu9dzAdOIhefvosgCUhZVqn5UrfH09tTA+wsDTkWtA35qQyq2/3AylYiwan8AwLrAPZYX1pGXtLT8UnE3PKeHSGLG"}	2026-05-28 21:33:10.162+02	2026-05-28 21:33:10.162+02	\N
01KSVPWAJ6403XDDC519D84VYE	princelulinda10@gmail.com	emailpass	authid_01KSVPWAJ6G79SQV5S2Q26FGGG	\N	{"password": "c2NyeXB0AA8AAAAIAAAAARHiSgF0eulhOxwj6ZYb6rp880P22gtTWakBIX5C/8YjulW758iuTDgnb1BbBMhY3TGH/4l27tudPkt3zh42OxIn/Z9YmZ0uoa3eJuMG6YG2"}	2026-05-30 07:49:29.03+02	2026-05-30 07:49:29.03+02	\N
01KSWS7TY782BYWTE6PBXXV0ZK	princelulinda11@gmail.com	emailpass	authid_01KSWS7TY7W4PDKT3K7A9ZPYCK	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAaf2dJTq7CdHVlC4MoV1WOOb+Q7/hwEPkz64kFG7tDTQL0ujhkwSOe5LibFQhG4MYIeXLImGGjJocNFs2pADrcjhdMN2wXXEZUxhzoN/Si4K"}	2026-05-30 17:49:57.832+02	2026-05-30 17:49:57.832+02	\N
01KTEM0BVX1R32XHW0AXF0ED2N	108982621194333547846	google	authid_01KTEM0BVY5132SFAV1H149V4W	{"name": "Lulinda Prince", "email": "princelulinda@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocIq6pG69c5UYzehBObwDrmw38l7tl8qdY1_0zhKGeZoWh4B7A=s96-c", "given_name": "Lulinda", "family_name": "Prince"}	\N	2026-06-06 16:04:49.919+02	2026-06-06 16:04:49.919+02	\N
01KV52QSB67RS9QYX7X2YW2636	princelulinda652@gmail.com	emailpass	authid_01KV52QSB6KCFEFGP4DHVBFPN3	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAeYcIelZxo34NIZ9Dr4sxRiA0LE9W/uR3Tt3Q/Hq1dooWeGKadaEru/8Rit0sKXKz107Cutg3d82Q+rk/tO8v3tXscHu063FYNaMIkxI/Am9"}	2026-06-15 09:25:34.952+02	2026-06-15 09:25:34.952+02	\N
01KV54R4B5X75NFNWM8VS6J11P	testvendor@example.com	emailpass	authid_01KV54R4B6M7GYEJ4GXWR3GEKC	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAcXmHe240FQ2bhNQoldBQdbgRup0Js6TNdpBLeL6Tyd9vq2gqMP2QLrIUW2Oji/gFhAdasCkFC+lh826S4JR/5adtpzRJWIHMuDzSB7i1+nF"}	2026-06-15 10:00:43.367+02	2026-06-15 10:00:43.367+02	\N
01KV56RDJXN9S52DJ4KJ6KTDJX	princelulinda02@gmail.com	emailpass	authid_01KV56RDJXKE7M18TXCTM63A6C	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAUnIqmllS7f9H9rVTtUw//ocYR9Tx/7erUs6vx5V1xOSxS+ugJYN31fSNSaKgmiE9/OozVu3ezmlr3MZx7uliQuQB+0/V1cvoaKj2o6zV98O"}	2026-06-15 10:35:49.982+02	2026-06-15 10:35:49.982+02	\N
01KV69XRE7WCHDY7GT194P9NQS	princelulinda333@gmail.com	emailpass	authid_01KV69XRE72ETY0V232QHGV6J5	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAcqVpGy26kpYpX1dN3jHDZ0tBYlg/p8FVNVGL0U67m4ZPOTKHX4gsUa6l544qDrgkrZWE1NNh2CIccGcfKsfxg18pEO7FnB8FKXgCSI2fCcx"}	2026-06-15 20:50:25.096+02	2026-06-15 20:50:25.096+02	\N
01KWSMFX3SC9YD5H7TYQ9B5065	princelulinda87@gmail.com	emailpass	authid_01KWSMFX3T0E0MNAD50BQA1CVG	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAXmq/AF/v/Gyv8Np1FMtTHlOiQ4lzTB2WfDe/l+vuJZZIdzOXxwjyVS62KfnFpWQXPklYoAnO6Hd+PvDcj5JOeGEzMSFmxkK/jrMFhTet6qo"}	2026-07-05 19:16:21.5+02	2026-07-05 19:16:21.5+02	\N
01KV56WXHN5TPRTCMCNY6WYB9S	princelulinda61@gmail.com	emailpass	authid_01KV56WXHNWPD4FJBPCKR4FXV1	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAZXR53SMuhAbPTSDWANANCHcaEGiX2dplVffd9Pz3hyjHiC/Vju3Mwmpg7/pL3fx6qTVglJXnhsG7CA8r8jVDZCfgaxvBqvuxKpRDJiZtKbF"}	2026-06-15 10:38:17.397+02	2026-06-15 10:49:43.196+02	\N
01KV5AFEKDX3239SZGRNSWEA7Q	princelulinda012@gmail.com	emailpass	authid_01KV5AFEKE05VZFMD54HZWC5W3	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAWhI+n455Ko8RT3TvOl/2gtq5V6PojR7OqO52uxFpIBaR8DkZ+ydYvmV1H6jYevgxnGzQ3i1KXd0jcHPzSN+/SKNLs6MhWDJdxKLbd71v+O2"}	2026-06-15 11:40:50.414+02	2026-06-15 11:40:50.414+02	\N
01KV5BJNTZ69S9WEX588A3TPFC	princelulinda0001@gmail.com	emailpass	authid_01KV5BJNV0G2JVFH7Y3HSQAKPY	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAcCb/8URFN3+IvJORDsvSIj4EmttUhe+Zh0geytJt4NTcv7DnlfVl7GgJiqNZ/2zJ1dQ6pBXGUJpvOpNoEMVSCyr4yL4Vsf94txaucW1eAN3"}	2026-06-15 12:00:04.704+02	2026-06-15 12:00:04.704+02	\N
01KV5BN08H3RQJNKAB43WJ6WDH	prince@gmail.com	emailpass	authid_01KV5BN08HFC5239YBN9SM3X6Q	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAccAv3dMe4Pmola94rKAUkCaUmID94Kmyyz8Olt7cxfO5I5luPzgowFJsF4YBU7fhIIiW5/aDm5Qij8B1yx0bbMT4MzILDVuN5FsUNP1XSfq"}	2026-06-15 12:01:20.913+02	2026-06-15 12:01:20.913+02	\N
01KV5CHGRRXP0Y7T0FPXD1PGTW	princelulinda1002@gmail.com	emailpass	authid_01KV5CHGRSJN97BQ66DS6X142Y	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAf+nbpidRPX/I/rHNHHHzSLxdBMecWdNhFeGRzRULfQNLnW7GhpPPIOaWFlN9koRlNZqi3vP7Zt6ZgQrHNEluRzuVfkQoyyON67QmMdrILG4"}	2026-06-15 12:16:55.321+02	2026-06-15 12:16:55.321+02	\N
01KV65ZRR2KYK6RM5VPW128XXE	princelulinda2@gmail.com	emailpass	authid_01KV65ZRR29AGAN8CME1Y0DTA8	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAcv9zzruavyUa6p1c6KL+E5xEwDpnk3ow4GWEIewdB4vpWk24GFa6MFVtSvpBCt5w9VDbFzkFw96Y8jzIWLHCuBQcT1LGEk6Jk17RZ22kNGD"}	2026-06-15 19:41:36.644+02	2026-06-15 19:41:36.644+02	\N
01KWTFT49D9A2Q8F16YS3EGQNB	113907612732063002534	google	authid_01KWTFT49FQHKSA1NCZVMEZS8V	{"name": "Melance Nzohabonwanayo", "email": "melancenzohabonwanayo@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocIPBojZ2w2TejHLnVIK1uJ6xpypWeEQ9obYId5X8Hpm_tSwmQ=s96-c", "given_name": "Melance", "family_name": "Nzohabonwanayo"}	\N	2026-07-06 03:13:48.081+02	2026-07-06 03:13:48.081+02	\N
01KWTJAF0VHPGGWJ17YCGST441	princelulinda562@gmail.com	emailpass	authid_01KWTJAF0VVSBSVA4RCTCVVW0N	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAb0avIPoLM2pPnf4iYADLu02X/PADtJsanc94mRKP5KQVP31zjbyoisGP6C7qHGsvO30RbYXT4QYlULaEYx9frj/G8Ef9xAPQbetP1veYUbq"}	2026-07-06 03:57:40.508+02	2026-07-06 03:57:40.508+02	\N
01KWTJDTP0TZZ2FWEP6KV3KDKW	princelulinda3200@gmail.com	emailpass	authid_01KWTJDTP09MK80G456S7SBPGN	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAftNshFJa/6tbNzjvfWSZnMF3SyVHn/pL0x/6ZBWWD4xXKu6wwCz/PKujfvRjHpzK8l6q9kd2nWVtwgYJjq48rXrgWtNkHAL0KWrY3Hkkg06"}	2026-07-06 03:59:30.753+02	2026-07-06 03:59:30.753+02	\N
01KWWN41SGQD624V5MDH7METTT	princelulinda+1@gmail.com	emailpass	authid_01KWWN41SH31MN1VSFE540JFHJ	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAeoChCNF5DVe6MiRVXSBbLrgCpfLjsONeQPvs3qTrwgZ/5AJVvj65APSpct5q5lEh5rVnVLvPOWwUBvECFNFnOyPMhvVZSPvyjqzj7qppqPB"}	2026-07-06 23:25:04.945+02	2026-07-06 23:25:04.945+02	\N
01M019M0VF3WDW574D98THHSTD	princelulinda+76@gmail.com	emailpass	authid_01M019M0VFMVS74E77G4ZE2M1C	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAcVv1f63g9FnDIv59o7JKzSvaUxbchjqrxUTFr5Jz0i/1zcEkwDv+laEcb6bBIJG+1CuAz1yOBeoBmL+tmxv3mw/xK0+RZgG3/KZFVgvJVb1"}	2026-08-15 01:27:22.992+02	2026-08-15 01:27:22.992+02	\N
01KWXQ71CPT9NSQATJ2P2M1DQE	117530451055197446551	google	authid_01KWXQ71CQP932KYCYRTG2TP6S	{"name": "ygo", "email": "ygo.solution@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocLGAM0Ry6Tvf0CC4fJF8E83f0YjXMfPUobnJRPdPFizlPyAOg=s96-c", "given_name": "ygo"}	\N	2026-07-07 09:20:54.425+02	2026-07-07 09:20:54.425+02	\N
01KWXQCXQHYAPXQPEHSNCEJ9K4	117780112494511990282	google	authid_01KWXQCXQJS4MSHHMYVZWBDM0M	{"name": "Lulinda Prince", "email": "princelulinda12@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJnjlLUR8DzwFm3jHF8NiXFABWUwX_Xwv7Csw8GnyG5jrH89w=s96-c", "given_name": "Lulinda", "family_name": "Prince"}	\N	2026-07-07 09:24:07.282+02	2026-07-07 09:24:07.282+02	\N
01KXDCKEV3Y9AKDET55FNXJ3MP	113907612732063002534	google-onetap	authid_01KXDCKEV31BJHP4RYPND0BMZA	{"name": "Melance Nzohabonwanayo", "email": "melancenzohabonwanayo@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocIPBojZ2w2TejHLnVIK1uJ6xpypWeEQ9obYId5X8Hpm_tSwmQ=s96-c", "given_name": "Melance", "family_name": "Nzohabonwanayo"}	\N	2026-07-13 11:23:17.988+02	2026-07-13 11:23:17.988+02	\N
01KZSMAT58F68SWHARJT41HJV7	loyaltytest_1786492840@example.com	emailpass	authid_01KZSMAT59RX6KP1X9JBZ8MXTA	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAU33Vp/fSwVUJY+l76s3wnZK2Crh1HF2hXrgB5rnYSSfQeHvrAE/3d8yL+6gQ3lLANcLwrE1d5lyDo7Fe01VYbHb5xN5hcuEW6W5lYsPLUA4"}	2026-08-12 02:00:40.105+02	2026-08-12 02:00:40.105+02	\N
01KZSMBZ80Z6KX1RNSEG3E0K08	loyaltyspin_1786492878_1@example.com	emailpass	authid_01KZSMBZ800M84CNVTNCJTPFEZ	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAYaTcjJYPpqFDVovwFe4usXRZa4fdjVGrTLCg/6K2rXSIMBWfWJIibAzygqF6kjlAv/w3LRll0IyhTKPjNdOZVQHmTq+euPzTF3ikB4HmmTo"}	2026-08-12 02:01:18.081+02	2026-08-12 02:01:18.081+02	\N
01KZSMBZG51P1TW2Y6HM9017F3	loyaltyspin_1786492878_2@example.com	emailpass	authid_01KZSMBZG5VSWYB00W8KA340AE	\N	{"password": "c2NyeXB0AA8AAAAIAAAAATCZ5Niji8NfPHwnjkU1+VbjklVwYLmlGH959bt56TvW7EoxjkYfv2MWLPHPS7KJXZ2u7cttTLvGJkcPTQBLTPHrRE9EmENcs4wSLQr6U/Y7"}	2026-08-12 02:01:18.341+02	2026-08-12 02:01:18.341+02	\N
01KZSMBZR9D45QA3S1QFV3J1VS	loyaltyspin_1786492878_3@example.com	emailpass	authid_01KZSMBZR902D3F11JK6AJFYQG	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAd4MSBvJ7wj7aIMg1yGoDKD+Z9sBuNmzofvEO1ld7tnEU6JU1ekl2bIEaxKIhTGkzBv4GHAt/bti3i7uqfPbdi3y2QHfB7PyiIpV7EUHccMh"}	2026-08-12 02:01:18.601+02	2026-08-12 02:01:18.601+02	\N
01KZSMC002RAMPHRG2QNBXHW3N	loyaltyspin_1786492878_4@example.com	emailpass	authid_01KZSMC003CJY6E6J67H3RCNKB	\N	{"password": "c2NyeXB0AA8AAAAIAAAAATI0VPsGjil8Z/3xSm7A2HJVoC/nqS8pKD5DQBQ/NeDJAQCVzS1pC/SHslwg55NP/a40B/rAyNWrKY5ZUeL0LzAmhOf4rNAGDFUvlaF9M7nR"}	2026-08-12 02:01:18.851+02	2026-08-12 02:01:18.851+02	\N
01KZSMC07TFVC9MEVXDB4ZFF8G	loyaltyspin_1786492879_5@example.com	emailpass	authid_01KZSMC07VVSNVQ5EZD4S78F07	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAfseJFk6MQYvnKkVEdQ6p4ysfxsUgcH9LKGEQzOAmL/wKycHF+lqiPQSVVCSIAtWu85VCgQvMCeSsOlfCzW6hH8h6WHtp6g+lxeNeRl28BvP"}	2026-08-12 02:01:19.099+02	2026-08-12 02:01:19.099+02	\N
01KZSMC0FMZJRZAK6ZR8AHS3T5	loyaltyspin_1786492879_6@example.com	emailpass	authid_01KZSMC0FN3S22P81BEG93PM48	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAeCpbVhE/T70A5Taw43kg55KG1FNYWnU0Ka8kfxBmxl+cCOpUfF4dkr3JBtBLRoGx1kTlukiakaxPdK85oeVv/Z1NV+ZRv7yHFduTvnPIpDV"}	2026-08-12 02:01:19.349+02	2026-08-12 02:01:19.349+02	\N
01KZSMC0QY3Y3XHCHBSG17SEDN	loyaltyspin_1786492879_7@example.com	emailpass	authid_01KZSMC0QYQKZJNVX9MS5PAFF9	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAUj/ZQYStJ4f7mCXcVNhzP1jQAbavIlpiG9zo/5bylRy9tQmro0G2GG25aaxCTI1+MrrRh/z+3qHc/mtWF5m01YDXVYhohHM9rFlfeEE7JeA"}	2026-08-12 02:01:19.614+02	2026-08-12 02:01:19.614+02	\N
01KZSMC10300GWSG9DZTNZPQZS	loyaltyspin_1786492879_8@example.com	emailpass	authid_01KZSMC103P379067ZJXGHEFJC	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAXWwjz4qrk6cOexWeJ4nruSl/pWHfomZAGG5Ek/fRMaVEGfGgNcNFs6+LVK5pf+u4qE7ZTWH8h2VAtGKqaOAGojiZ/dRolBPofLtcnzzqcNI"}	2026-08-12 02:01:19.876+02	2026-08-12 02:01:19.876+02	\N
01KZSMC17VXBPZD8KRJR4NDXTS	loyaltyspin_1786492880_9@example.com	emailpass	authid_01KZSMC17VE6WHD0X05Z7ZP2RG	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAQ/H7Jv+PtVYZyus0bBZJa/4GUw9upG652beknx0EgFQiFagNdBq4uWnoU2MW1IB0A28YoSLHNjVtvvn0TMYHYJt2hvB6wuD3Hr2fpQxecHB"}	2026-08-12 02:01:20.123+02	2026-08-12 02:01:20.123+02	\N
01KZSMC1FBXXWPN3NA2RTNAVME	loyaltyspin_1786492880_10@example.com	emailpass	authid_01KZSMC1FB5A60SDVC425YMAN2	\N	{"password": "c2NyeXB0AA8AAAAIAAAAASYabNkm53BQzfwoGf8/Mog3ly7k7TavqjQ6LboL/qlyO1pbbwkBvXTpWa/jqzV3Y8A1Srgow7JDZDZPctsUGoYoo4HPEqCVL9+JGW2k4hqj"}	2026-08-12 02:01:20.363+02	2026-08-12 02:01:20.363+02	\N
01KZSMC1QQCWKW34FBJG7ERNK2	loyaltyspin_1786492880_11@example.com	emailpass	authid_01KZSMC1QQTP5HPGAPTPNXW26Q	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAe2GrVWlJaeIn/iFpC8kk1HSOYt6HqmlHw84e/d5dAFa051I83O54v+V6a6Xvekcw2eS77vmtGjLKaP5ihOvd75GSOMzz8TaAjg8K2xtYv7a"}	2026-08-12 02:01:20.631+02	2026-08-12 02:01:20.631+02	\N
01KZSMC2113SSNW1AT173AGC1J	loyaltyspin_1786492880_12@example.com	emailpass	authid_01KZSMC211K3EXD6KV663KG1ZQ	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAWDkL+RxC2R4Pg1mjNh6KrMGbaSi9Nbof/28IJvZFzBKnvVX7Jd0F+8Ot++ypuTjrClHYV4uOoyQCRsOkrNTPb/dU6baaWeCWPIdgCY62VgY"}	2026-08-12 02:01:20.929+02	2026-08-12 02:01:20.929+02	\N
01KZSMEXM4N8VZH3STV561NF0Z	loyaltyspin2_1786492974_1@example.com	emailpass	authid_01KZSMEXM49GBRBN29F44ACZ7T	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAQdh2btac3dfMbM7qfDGB6pu0VMO6BPiGs4lbOeIlLCuLR8evw0r1z/yAURgCLsabT1dnG9iEqCvq4ljuWihENV7wuhktnrPu470mGYs9JD1"}	2026-08-12 02:02:54.725+02	2026-08-12 02:02:54.725+02	\N
01KZSMEXYJBX2P740RD5BNA9XV	loyaltyspin2_1786492974_2@example.com	emailpass	authid_01KZSMEXYJ5AVJYN48N086SVX8	\N	{"password": "c2NyeXB0AA8AAAAIAAAAATJ9Y9MKuKVSXD37WQWfuo5iBEuFyMElsJ+9lgdAFrZVwrgiQMkIkvtINxGn6mdpNsk1gtI8bL3dAa4zKwdVfQ7vL5X/WwrvwyBJaubAHnv4"}	2026-08-12 02:02:55.058+02	2026-08-12 02:02:55.058+02	\N
01KZSNDA7Q6TEJYFR56F54AA63	flashsaletest@example.com	emailpass	authid_01KZSNDA7RBN8RA48W9WCD9NQM	\N	{"password": "c2NyeXB0AA8AAAAIAAAAARB9i4jclwIGI93GvlLyqiOjniu2bfLK0sM/HdkQwONVyqd09WIfG+IEnPwznSDQk+ICCx+ntOR96Du+B2guGjTH5v4RlaErdUbwfiCfBiM6"}	2026-08-12 02:19:30.681+02	2026-08-12 02:19:30.681+02	\N
01KZSNE0M3PG9F85WKXT1MTVP0	flashsaletest2@example.com	emailpass	authid_01KZSNE0M36DT75HAQQ1XYT0EW	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAYcKmhxxVFg9XvSu4668mX3tQXudWZ2HC4Y9/q4Qe8c3h8RlUh3UYgzVKMB+iHndp1umrbtdwt2K+oLE1gcvpWVyzOEpXxuNsLFkuI7+pEUz"}	2026-08-12 02:19:53.604+02	2026-08-12 02:19:53.604+02	\N
01KZTETPYD5KEE0G2ECANQ4AD8	princelulinda320@gmail.com	emailpass	authid_01KZTETPYDM6S7FMMNGQXTVHKF	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAdFDtin1RmUb8zRHnewJ8tzIYSfrbs6HzXSrlaTj3tlQoPYeHW27PK1XFnZWyHIhT6ExB1Y4KmJjKMXSHvB6tZIIL1XEsRwr/Lc2RpVL43/L"}	2026-08-12 09:43:44.079+02	2026-08-12 09:43:44.079+02	\N
01KZTFASSNGTB1VH9RFK8KNDR3	referraltest_1786521151@example.com	emailpass	authid_01KZTFASSQPBTYBMRHAT7S1ZXA	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAS2YrCs0YKSjVoL+/rw1Mayy3OQwGKspP+M6E8jsZLQ8Y/vj+bfPIVi2dk+BQF+rx0fgxfWm2BQcSYbAuGWptFU+VYa1E8kGQkvOtVw5CPzk"}	2026-08-12 09:52:31.289+02	2026-08-12 09:52:31.289+02	\N
01KZV2PT8QYH4YHA0TNGKTAR29	princelulinda+2@gmail.com	emailpass	authid_01KZV2PT8Q3Z6BXEN6ZJ7BYRP8	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAUJTRc+nf+OpltzflruyL9ScuI/RSLq6vtIuz44b/b7/GmrpwlURZeXpUfNUHr1LG5yVQ8yssD9aBPMMNuEyelw5bw6r/VWPZro6CZU4b2RG"}	2026-08-12 15:31:07.928+02	2026-08-12 15:31:07.928+02	\N
01M0196VW9628WSB28B7VQ4YG9	princelulinda+78@gmail.com	emailpass	authid_01M0196VW9Q4ZQ0VCQXACR0D9X	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAdVHT0zZHW349sm+0dTJnv9gtcfofY/d+2g6zBMoAvZOBh+lm65G3RHwCBPzPw1OHXm+f+oILB7s2tF38SZGd6ggphVKy7t0oYLryxNeWx9+"}	2026-08-15 01:20:11.913+02	2026-08-15 01:20:11.913+02	\N
01M019BF4HRENA4YTEWJBFDZGR	princelulinda+11@gmail.com	emailpass	authid_01M019BF4JJPDQYTEAPNRZERWG	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAfKVeSZ6lkdHfqKaX52opjuIqSps2U1c5o6PpBm49Uzfs1G9Yhza88SqpbDiFLJ1OCJaaMtsEjcZikseH60PDTzabJv0jNBYwW9Dqu5Zpi5J"}	2026-08-15 01:22:42.707+02	2026-08-15 01:22:42.707+02	\N
01M01ABZ24QWV7316SQS70DK6Z	princelulinda+13@gmail.com	emailpass	authid_01M01ABZ24PD8R0B2FAEMNDSJ4	\N	{"password": "c2NyeXB0AA8AAAAIAAAAATAG2j9AeVbkxBCJcO4VSYUKKxZlRhIUriTeikTeI+aSoTIL1gJNgtTL8EnWuAPtBhJu8WgsSwpGTkZ+8BfHs0lbxoxkEgfP4RtKspTZ47X9"}	2026-08-15 01:40:27.589+02	2026-08-15 01:40:27.589+02	\N
01M01C3VXWKZ6HT2C1SDZ95TAF	princelulinda+87@gmail.com	emailpass	authid_01M01C3VXW1VNAPWJ1AFTXP1KM	\N	{"password": "c2NyeXB0AA8AAAAIAAAAARvBbQyViwTdE+fXnn9j3mrWOTjPazjN46tki7HxdNviwAGAvV94sI1CVyzzCh6Ix8e7m/TEe0hC4+f5MAGlQHS3vKwEuDUC/h52qE0ViThv"}	2026-08-15 02:10:59.389+02	2026-08-15 02:10:59.389+02	\N
01M01CP98B6K5MA1C68A8C07R8	probe-1786753262@example.com	emailpass	authid_01M01CP98CWR4XWQKK2TAKGBBM	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAX976plpM8w+uR9A1sMW555QMgdMTOYaF9hwgu/WSIgFtPlJRTsb7OQPeTyo9Wj+LSqJCBv0GFnUWpwmqbRCbf6gANb57KFZt0R27lMYfUMb"}	2026-08-15 02:21:02.862+02	2026-08-15 02:21:02.862+02	\N
01M01D4F8F406DSXH1K45SW92G	princelulinda+888@gmail.com	emailpass	authid_01M01D4F8GDRKJKR2RN4REZ7R1	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAWRnEU7bxK/4ZViMIujluMBuMaMTKVI3K4fG1pJrOtdKkntl3JT4mMoKZHMj7RKGFL2aLBP0cyY3u9/prM7FnQ45+FV7JqSCfELxDVeOnSWI"}	2026-08-15 02:28:47.76+02	2026-08-15 02:28:47.76+02	\N
\.


--
-- Data for Name: publishable_api_key_sales_channel; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.publishable_api_key_sales_channel (publishable_key_id, sales_channel_id, id, created_at, updated_at, deleted_at) FROM stdin;
apk_01KSCR9E4FPV3BZ6DTK9AQ9BCY	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pksc_01KSCR9E4RXPEG72XME0C41ENS	2026-05-24 12:25:30.776504+02	2026-05-24 12:25:30.776504+02	\N
apk_01KSCR9E9G4ZV5ENRXW1WS8XVC	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pksc_01KSCR9E9QTMRMEBW2MWYB8HZ8	2026-05-24 12:25:30.934812+02	2026-05-24 12:25:30.934812+02	\N
\.


--
-- Data for Name: push_token; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.push_token (id, recipient_id, recipient_type, token, device_type, created_at, updated_at, deleted_at) FROM stdin;
01KSHXQN5BXTGCHQQ92E1G7Y78	01KSCSTSPDSEAN744XV198F4RD	vendor	ExponentPushToken[yPZW9CCfi5no4U6jT9yM7r]	android	2026-05-26 12:36:51.756+02	2026-05-26 12:36:51.756+02	\N
01KSR5PFX05PGTJ2S4M53TZAG7	01KSDE9JW0MFK1W1NWQ29QV25V	vendor	ExponentPushToken[2vxx78DggNgc6vwROe_YGI]	android	2026-05-28 22:51:28.801+02	2026-05-28 22:51:28.801+02	\N
01KSR5PFX5Y39M3WW3GMMY8GQP	01KSDE9JW0MFK1W1NWQ29QV25V	vendor	ExponentPushToken[2vxx78DggNgc6vwROe_YGI]	android	2026-05-28 22:51:28.805+02	2026-05-28 22:51:28.805+02	\N
01KSR5PFX7AGZ397PQV6746Z8Z	01KSDE9JW0MFK1W1NWQ29QV25V	vendor	ExponentPushToken[2vxx78DggNgc6vwROe_YGI]	android	2026-05-28 22:51:28.807+02	2026-05-28 22:51:28.807+02	\N
01KSR5VYSNSDCP7WH9PH2W8YCM	01KSCSTSPDSEAN744XV198F4RD	vendor	ExponentPushToken[2vxx78DggNgc6vwROe_YGI]	android	2026-05-28 22:54:27.893+02	2026-05-28 22:54:27.893+02	\N
01KSZ0QY7H9QM22E9KYJ3JCN75	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	ExponentPushToken[2vxx78DggNgc6vwROe_YGI]	android	2026-05-31 14:39:34.385+02	2026-05-31 14:39:34.385+02	\N
01KSZ84NQKXHGX4MRR7ADBFF5S	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	ExponentPushToken[OXo6MSDtGUOUAxkyfkd9As]	\N	2026-05-31 16:48:51.699+02	2026-05-31 16:48:51.699+02	\N
01KSZBKNHEGW9H75KEKJADSRRS	cus_01KSWS7V39C4SDB1YTY9K83SMS	customer	ExponentPushToken[JggvTGL9ivbGpq6aMHjaz-]	\N	2026-05-31 17:49:28.751+02	2026-05-31 17:49:28.751+02	\N
01KSZBVG89GFSSBY8BD5WN6YNA	cus_01KSVPWBFY9T5MZXK47CYD788Q	customer	ExponentPushToken[JggvTGL9ivbGpq6aMHjaz-]	\N	2026-05-31 17:53:45.481+02	2026-05-31 17:53:45.481+02	\N
01KT01CMM17DWC39T16Y2PCQZS	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	ExponentPushToken[JggvTGL9ivbGpq6aMHjaz-]	\N	2026-06-01 00:10:07.105+02	2026-06-01 00:10:07.105+02	\N
01KT0D0F0YA9CRJYA3B5FTFPV2	cus_01KSVPWBFY9T5MZXK47CYD788Q	customer	ExponentPushToken[OXo6MSDtGUOUAxkyfkd9As]	\N	2026-06-01 03:33:11.07+02	2026-06-01 03:33:11.07+02	\N
01KTEPK6AM2PHT10EA5EP2PM1V	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	ExponentPushToken[Ok0iu1DNVwuhZHDWdk2dav]	\N	2026-06-06 16:50:03.989+02	2026-06-06 16:50:03.989+02	\N
01KV558X6PH8MRBS0S0C29HYR8	01KSCSTSP7N25SPSF2H5AK45FY	vendor	ExponentPushToken[YJsaidB7p0o8zMLE5EbhuU]	android	2026-06-15 10:09:53.111+02	2026-06-15 10:09:53.111+02	\N
01KV55CWKFSDAS09MF421D28AJ	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	ExponentPushToken[YJsaidB7p0o8zMLE5EbhuU]	android	2026-06-15 10:12:03.567+02	2026-06-15 10:12:03.567+02	\N
01KV57N75FAXCPW7WE8HJBADAE	01KV57JBZBPRJ93AM3PSKFTMMH	vendor	ExponentPushToken[YJsaidB7p0o8zMLE5EbhuU]	android	2026-06-15 10:51:33.679+02	2026-06-15 10:51:33.679+02	\N
01KV5BQ4DECB73VECZW2Y0B4P1	01KV5BPJD0BHQNMDBVA7EPR3R1	vendor	ExponentPushToken[YJsaidB7p0o8zMLE5EbhuU]	android	2026-06-15 12:02:30.702+02	2026-06-15 12:02:30.702+02	\N
01KV5CJAHMMGG3H99KDG6AAGH6	01KV5CHYWYZVSNYGB0RXEYG5CK	vendor	ExponentPushToken[YJsaidB7p0o8zMLE5EbhuU]	android	2026-06-15 12:17:21.716+02	2026-06-15 12:17:21.716+02	\N
01KV661WA54RFH1565QPGSMBDZ	01KV660ATKQP58J260MPW7RQ8R	vendor	ExponentPushToken[YJsaidB7p0o8zMLE5EbhuU]	android	2026-06-15 19:42:45.829+02	2026-06-15 19:42:45.829+02	\N
01KV69YXNRSCBNXZA3YCMH6W6J	01KV69YB45Q6QNDRG5VPA4X643	vendor	ExponentPushToken[YJsaidB7p0o8zMLE5EbhuU]	android	2026-06-15 20:51:03.224+02	2026-06-15 20:51:03.224+02	\N
01KV69YXNVVB13M99E63G2ACW0	01KV69YB45Q6QNDRG5VPA4X643	vendor	ExponentPushToken[YJsaidB7p0o8zMLE5EbhuU]	android	2026-06-15 20:51:03.227+02	2026-06-15 20:51:03.227+02	\N
01KV6VQ2ZD9QXS45HDYGMRMNYS	01KSCSTSP7N25SPSF2H5AK45FY	vendor	ExponentPushToken[nTVy2ADDepUMzihHAWCCPU]	android	2026-06-16 02:01:20.878+02	2026-06-16 02:01:20.878+02	\N
01KVACB4ADHP9H4WQAR70MHWRP	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	ExponentPushToken[2mafRUN2ix8Av_IDsOvG-N]	\N	2026-06-17 10:49:38.126+02	2026-06-17 10:49:38.126+02	\N
01KVACB4AMFFDCS7D086DKV6HA	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	ExponentPushToken[2mafRUN2ix8Av_IDsOvG-N]	\N	2026-06-17 10:49:38.132+02	2026-06-17 10:49:38.132+02	\N
01KWTJFRTW2RM8WZF4M63CBTHJ	cus_01KWTJDVCJA6KHS6TX3DTG1P1K	customer	ExponentPushToken[2mafRUN2ix8Av_IDsOvG-N]	\N	2026-07-06 04:00:34.396+02	2026-07-06 04:00:34.396+02	\N
01KZTF0QR9N8GPFG0H5C3GNQ9D	cus_01KZTETSA89TK03RE3G06BXQDJ	customer	ExponentPushToken[2mafRUN2ix8Av_IDsOvG-N]	\N	2026-08-12 09:47:01.513+02	2026-08-12 09:47:01.513+02	\N
01KZV2VVZBT0BMMRTAQG3X65HS	cus_01KZV2PTYGTZ4E2VCQ7R28NYVF	customer	ExponentPushToken[2mafRUN2ix8Av_IDsOvG-N]	\N	2026-08-12 15:33:53.515+02	2026-08-12 15:33:53.515+02	\N
01KZYKK4DZ4S4KR1CCH2PT17SB	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	ExponentPushToken[ktxA_0Gq9uypChF_7YaidD]	\N	2026-08-14 00:23:56.352+02	2026-08-14 00:23:56.352+02	\N
01M0194FE53H6F5T4W0T0TSRG5	cus_01KWTHT7FNHAP08HMCSJ9NW4P9	customer	ExponentPushToken[ktxA_0Gq9uypChF_7YaidD]	\N	2026-08-15 01:18:53.637+02	2026-08-15 01:18:53.637+02	\N
01M0194FE672CV95K0890TNMDV	cus_01KWTHT7FNHAP08HMCSJ9NW4P9	customer	ExponentPushToken[ktxA_0Gq9uypChF_7YaidD]	\N	2026-08-15 01:18:53.638+02	2026-08-15 01:18:53.638+02	\N
\.


--
-- Data for Name: referral; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.referral (id, referrer_customer_id, referred_customer_id, code_used, status, rewarded_at, referrer_coupon_id, referred_coupon_id, created_at, updated_at, deleted_at) FROM stdin;
01KZTFB3MFM46WGA0XRKV1R7M4	cus_01KZSMAT6WFYWBGMFDGBSQVMKG	cus_01KZTFASX63451FWPYQZST4A8M	EM1IGXG	rewarded	2026-08-12 09:53:02.418+02	01KZTFBR5S9VKTZMZM6XR5E1W7	01KZTFBR658SADXNPQ4583EFMA	2026-08-12 09:52:41.359+02	2026-08-12 09:53:02.452+02	\N
\.


--
-- Data for Name: refund; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.refund (id, amount, raw_amount, payment_id, created_at, updated_at, deleted_at, created_by, metadata, refund_reason_id, note) FROM stdin;
\.


--
-- Data for Name: refund_reason; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.refund_reason (id, label, description, metadata, created_at, updated_at, deleted_at, code) FROM stdin;
refr_01KSCR4YZ4B75HDYM01KFGAFV6	Shipping Issue	Refund due to lost, delayed, or misdelivered shipment	\N	2026-05-24 12:23:04.119432+02	2026-05-24 12:23:04.119432+02	\N	shipping_issue
refr_01KSCR4YZ41X6RG8T6JTBJKNDE	Customer Care Adjustment	Refund given as goodwill or compensation for inconvenience	\N	2026-05-24 12:23:04.119432+02	2026-05-24 12:23:04.119432+02	\N	customer_care_adjustment
refr_01KSCR4YZ45HPY825GEPX212WG	Pricing Error	Refund to correct an overcharge, missing discount, or incorrect price	\N	2026-05-24 12:23:04.119432+02	2026-05-24 12:23:04.119432+02	\N	pricing_error
\.


--
-- Data for Name: region; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.region (id, name, currency_code, metadata, created_at, updated_at, deleted_at, automatic_taxes) FROM stdin;
reg_01KSCR9E5TH7739ZGVPZHV9YR7	Europe	eur	\N	2026-05-24 12:25:30.814+02	2026-05-28 21:23:51.082+02	2026-05-28 21:23:51.08+02	t
reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	East	usd	\N	2026-05-28 21:24:33.371+02	2026-05-28 21:24:33.371+02	\N	f
\.


--
-- Data for Name: region_country; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.region_country (iso_2, iso_3, num_code, name, display_name, region_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
cd	cod	180	CONGO, THE DEMOCRATIC REPUBLIC OF THE	Congo, the Democratic Republic of the	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
ck	cok	184	COOK ISLANDS	Cook Islands	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
cr	cri	188	COSTA RICA	Costa Rica	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
ci	civ	384	COTE D'IVOIRE	Cote D'Ivoire	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
hr	hrv	191	CROATIA	Croatia	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
cu	cub	192	CUBA	Cuba	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
cw	cuw	531	CURAÇAO	Curaçao	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
cy	cyp	196	CYPRUS	Cyprus	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
cz	cze	203	CZECH REPUBLIC	Czech Republic	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
dj	dji	262	DJIBOUTI	Djibouti	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
dm	dma	212	DOMINICA	Dominica	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
do	dom	214	DOMINICAN REPUBLIC	Dominican Republic	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
ec	ecu	218	ECUADOR	Ecuador	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
eg	egy	818	EGYPT	Egypt	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
sv	slv	222	EL SALVADOR	El Salvador	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
gq	gnq	226	EQUATORIAL GUINEA	Equatorial Guinea	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
er	eri	232	ERITREA	Eritrea	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
ee	est	233	ESTONIA	Estonia	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
et	eth	231	ETHIOPIA	Ethiopia	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
fk	flk	238	FALKLAND ISLANDS (MALVINAS)	Falkland Islands (Malvinas)	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
fo	fro	234	FAROE ISLANDS	Faroe Islands	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
fj	fji	242	FIJI	Fiji	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
fi	fin	246	FINLAND	Finland	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
gf	guf	254	FRENCH GUIANA	French Guiana	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
pf	pyf	258	FRENCH POLYNESIA	French Polynesia	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
tf	atf	260	FRENCH SOUTHERN TERRITORIES	French Southern Territories	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
ga	gab	266	GABON	Gabon	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
gm	gmb	270	GAMBIA	Gambia	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
ge	geo	268	GEORGIA	Georgia	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
gh	gha	288	GHANA	Ghana	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
gi	gib	292	GIBRALTAR	Gibraltar	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
gr	grc	300	GREECE	Greece	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
gl	grl	304	GREENLAND	Greenland	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
gd	grd	308	GRENADA	Grenada	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
gp	glp	312	GUADELOUPE	Guadeloupe	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
gu	gum	316	GUAM	Guam	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
gt	gtm	320	GUATEMALA	Guatemala	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
gg	ggy	831	GUERNSEY	Guernsey	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
af	afg	004	AFGHANISTAN	Afghanistan	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.682+02	2026-05-28 21:24:33.371+02	\N
al	alb	008	ALBANIA	Albania	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.682+02	2026-05-28 21:24:33.371+02	\N
gn	gin	324	GUINEA	Guinea	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
gw	gnb	624	GUINEA-BISSAU	Guinea-Bissau	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
gy	guy	328	GUYANA	Guyana	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
ht	hti	332	HAITI	Haiti	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
hm	hmd	334	HEARD ISLAND AND MCDONALD ISLANDS	Heard Island And Mcdonald Islands	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
va	vat	336	HOLY SEE (VATICAN CITY STATE)	Holy See (Vatican City State)	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
hn	hnd	340	HONDURAS	Honduras	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
hk	hkg	344	HONG KONG	Hong Kong	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
hu	hun	348	HUNGARY	Hungary	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
is	isl	352	ICELAND	Iceland	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
in	ind	356	INDIA	India	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
id	idn	360	INDONESIA	Indonesia	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
ir	irn	364	IRAN, ISLAMIC REPUBLIC OF	Iran, Islamic Republic of	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
iq	irq	368	IRAQ	Iraq	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
ie	irl	372	IRELAND	Ireland	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
im	imn	833	ISLE OF MAN	Isle Of Man	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
il	isr	376	ISRAEL	Israel	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
jm	jam	388	JAMAICA	Jamaica	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
jp	jpn	392	JAPAN	Japan	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
je	jey	832	JERSEY	Jersey	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
jo	jor	400	JORDAN	Jordan	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
kz	kaz	398	KAZAKHSTAN	Kazakhstan	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
ke	ken	404	KENYA	Kenya	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
ki	kir	296	KIRIBATI	Kiribati	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
kp	prk	408	KOREA, DEMOCRATIC PEOPLE'S REPUBLIC OF	Korea, Democratic People's Republic of	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
kr	kor	410	KOREA, REPUBLIC OF	Korea, Republic of	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
xk	xkx	900	KOSOVO	Kosovo	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
kw	kwt	414	KUWAIT	Kuwait	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
kg	kgz	417	KYRGYZSTAN	Kyrgyzstan	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
la	lao	418	LAO PEOPLE'S DEMOCRATIC REPUBLIC	Lao People's Democratic Republic	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
lv	lva	428	LATVIA	Latvia	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
lb	lbn	422	LEBANON	Lebanon	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
ls	lso	426	LESOTHO	Lesotho	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
lr	lbr	430	LIBERIA	Liberia	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
ly	lby	434	LIBYA	Libya	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
li	lie	438	LIECHTENSTEIN	Liechtenstein	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
lt	ltu	440	LITHUANIA	Lithuania	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
lu	lux	442	LUXEMBOURG	Luxembourg	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
mo	mac	446	MACAO	Macao	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
mg	mdg	450	MADAGASCAR	Madagascar	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
mw	mwi	454	MALAWI	Malawi	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
my	mys	458	MALAYSIA	Malaysia	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
mv	mdv	462	MALDIVES	Maldives	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
ml	mli	466	MALI	Mali	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
mt	mlt	470	MALTA	Malta	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
mh	mhl	584	MARSHALL ISLANDS	Marshall Islands	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
mq	mtq	474	MARTINIQUE	Martinique	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
mr	mrt	478	MAURITANIA	Mauritania	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
mu	mus	480	MAURITIUS	Mauritius	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
yt	myt	175	MAYOTTE	Mayotte	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
mx	mex	484	MEXICO	Mexico	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
fm	fsm	583	MICRONESIA, FEDERATED STATES OF	Micronesia, Federated States of	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
md	mda	498	MOLDOVA, REPUBLIC OF	Moldova, Republic of	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
mc	mco	492	MONACO	Monaco	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
mn	mng	496	MONGOLIA	Mongolia	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
me	mne	499	MONTENEGRO	Montenegro	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
ms	msr	500	MONTSERRAT	Montserrat	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
ma	mar	504	MOROCCO	Morocco	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
mz	moz	508	MOZAMBIQUE	Mozambique	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
mm	mmr	104	MYANMAR	Myanmar	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
na	nam	516	NAMIBIA	Namibia	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
nr	nru	520	NAURU	Nauru	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
np	npl	524	NEPAL	Nepal	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
nl	nld	528	NETHERLANDS	Netherlands	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
nc	ncl	540	NEW CALEDONIA	New Caledonia	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
nz	nzl	554	NEW ZEALAND	New Zealand	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
ni	nic	558	NICARAGUA	Nicaragua	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
ne	ner	562	NIGER	Niger	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
ng	nga	566	NIGERIA	Nigeria	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
nu	niu	570	NIUE	Niue	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
nf	nfk	574	NORFOLK ISLAND	Norfolk Island	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
mk	mkd	807	NORTH MACEDONIA	North Macedonia	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
mp	mnp	580	NORTHERN MARIANA ISLANDS	Northern Mariana Islands	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
no	nor	578	NORWAY	Norway	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
om	omn	512	OMAN	Oman	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
pk	pak	586	PAKISTAN	Pakistan	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
pw	plw	585	PALAU	Palau	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
ps	pse	275	PALESTINIAN TERRITORY, OCCUPIED	Palestinian Territory, Occupied	\N	\N	2026-05-24 12:23:06.683+02	2026-05-24 12:23:06.683+02	\N
pa	pan	591	PANAMA	Panama	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
pg	png	598	PAPUA NEW GUINEA	Papua New Guinea	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
py	pry	600	PARAGUAY	Paraguay	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
pe	per	604	PERU	Peru	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
ph	phl	608	PHILIPPINES	Philippines	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
pn	pcn	612	PITCAIRN	Pitcairn	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
pl	pol	616	POLAND	Poland	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
pt	prt	620	PORTUGAL	Portugal	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
pr	pri	630	PUERTO RICO	Puerto Rico	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
qa	qat	634	QATAR	Qatar	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
re	reu	638	REUNION	Reunion	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
ro	rom	642	ROMANIA	Romania	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
ru	rus	643	RUSSIAN FEDERATION	Russian Federation	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
rw	rwa	646	RWANDA	Rwanda	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
bl	blm	652	SAINT BARTHÉLEMY	Saint Barthélemy	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
sh	shn	654	SAINT HELENA	Saint Helena	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
kn	kna	659	SAINT KITTS AND NEVIS	Saint Kitts and Nevis	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
lc	lca	662	SAINT LUCIA	Saint Lucia	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
mf	maf	663	SAINT MARTIN (FRENCH PART)	Saint Martin (French part)	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
pm	spm	666	SAINT PIERRE AND MIQUELON	Saint Pierre and Miquelon	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
vc	vct	670	SAINT VINCENT AND THE GRENADINES	Saint Vincent and the Grenadines	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
ws	wsm	882	SAMOA	Samoa	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
sm	smr	674	SAN MARINO	San Marino	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
st	stp	678	SAO TOME AND PRINCIPE	Sao Tome and Principe	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
sa	sau	682	SAUDI ARABIA	Saudi Arabia	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
sn	sen	686	SENEGAL	Senegal	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
rs	srb	688	SERBIA	Serbia	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
sc	syc	690	SEYCHELLES	Seychelles	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
sl	sle	694	SIERRA LEONE	Sierra Leone	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
sg	sgp	702	SINGAPORE	Singapore	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
sx	sxm	534	SINT MAARTEN	Sint Maarten	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
sk	svk	703	SLOVAKIA	Slovakia	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
si	svn	705	SLOVENIA	Slovenia	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
sb	slb	090	SOLOMON ISLANDS	Solomon Islands	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
so	som	706	SOMALIA	Somalia	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
za	zaf	710	SOUTH AFRICA	South Africa	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
gs	sgs	239	SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS	South Georgia and the South Sandwich Islands	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
ss	ssd	728	SOUTH SUDAN	South Sudan	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
lk	lka	144	SRI LANKA	Sri Lanka	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
sd	sdn	729	SUDAN	Sudan	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
sr	sur	740	SURINAME	Suriname	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
sj	sjm	744	SVALBARD AND JAN MAYEN	Svalbard and Jan Mayen	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
sz	swz	748	SWAZILAND	Swaziland	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
ch	che	756	SWITZERLAND	Switzerland	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
sy	syr	760	SYRIAN ARAB REPUBLIC	Syrian Arab Republic	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
tw	twn	158	TAIWAN, PROVINCE OF CHINA	Taiwan, Province of China	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
tj	tjk	762	TAJIKISTAN	Tajikistan	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
tz	tza	834	TANZANIA, UNITED REPUBLIC OF	Tanzania, United Republic of	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
th	tha	764	THAILAND	Thailand	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
tl	tls	626	TIMOR LESTE	Timor Leste	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
tg	tgo	768	TOGO	Togo	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
tk	tkl	772	TOKELAU	Tokelau	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
to	ton	776	TONGA	Tonga	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
tt	tto	780	TRINIDAD AND TOBAGO	Trinidad and Tobago	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
tn	tun	788	TUNISIA	Tunisia	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
tr	tur	792	TURKEY	Turkey	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
tm	tkm	795	TURKMENISTAN	Turkmenistan	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
tc	tca	796	TURKS AND CAICOS ISLANDS	Turks and Caicos Islands	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
tv	tuv	798	TUVALU	Tuvalu	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
ug	uga	800	UGANDA	Uganda	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
ua	ukr	804	UKRAINE	Ukraine	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
ae	are	784	UNITED ARAB EMIRATES	United Arab Emirates	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
us	usa	840	UNITED STATES	United States	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
um	umi	581	UNITED STATES MINOR OUTLYING ISLANDS	United States Minor Outlying Islands	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
uy	ury	858	URUGUAY	Uruguay	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
uz	uzb	860	UZBEKISTAN	Uzbekistan	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
vu	vut	548	VANUATU	Vanuatu	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
ve	ven	862	VENEZUELA	Venezuela	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
vn	vnm	704	VIET NAM	Viet Nam	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
vg	vgb	092	VIRGIN ISLANDS, BRITISH	Virgin Islands, British	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
vi	vir	850	VIRGIN ISLANDS, U.S.	Virgin Islands, U.S.	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
wf	wlf	876	WALLIS AND FUTUNA	Wallis and Futuna	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
eh	esh	732	WESTERN SAHARA	Western Sahara	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
ye	yem	887	YEMEN	Yemen	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
zm	zmb	894	ZAMBIA	Zambia	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
zw	zwe	716	ZIMBABWE	Zimbabwe	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
ax	ala	248	ÅLAND ISLANDS	Åland Islands	\N	\N	2026-05-24 12:23:06.684+02	2026-05-24 12:23:06.684+02	\N
dk	dnk	208	DENMARK	Denmark	\N	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:22:44.577+02	\N
fr	fra	250	FRANCE	France	\N	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:23:05.653+02	\N
de	deu	276	GERMANY	Germany	\N	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:23:05.653+02	\N
it	ita	380	ITALY	Italy	\N	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:23:05.653+02	\N
es	esp	724	SPAIN	Spain	\N	\N	2026-05-24 12:23:06.684+02	2026-05-28 21:23:05.653+02	\N
se	swe	752	SWEDEN	Sweden	\N	\N	2026-05-24 12:23:06.684+02	2026-05-28 21:23:05.653+02	\N
gb	gbr	826	UNITED KINGDOM	United Kingdom	\N	\N	2026-05-24 12:23:06.684+02	2026-05-28 21:23:05.653+02	\N
dz	dza	012	ALGERIA	Algeria	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.682+02	2026-05-28 21:24:33.373+02	\N
as	asm	016	AMERICAN SAMOA	American Samoa	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.682+02	2026-05-28 21:24:33.371+02	\N
ad	and	020	ANDORRA	Andorra	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.682+02	2026-05-28 21:24:33.371+02	\N
ao	ago	024	ANGOLA	Angola	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.682+02	2026-05-28 21:24:33.371+02	\N
ai	aia	660	ANGUILLA	Anguilla	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.682+02	2026-05-28 21:24:33.371+02	\N
aq	ata	010	ANTARCTICA	Antarctica	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.371+02	\N
ag	atg	028	ANTIGUA AND BARBUDA	Antigua and Barbuda	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.371+02	\N
ar	arg	032	ARGENTINA	Argentina	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.371+02	\N
am	arm	051	ARMENIA	Armenia	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.371+02	\N
aw	abw	533	ARUBA	Aruba	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.371+02	\N
au	aus	036	AUSTRALIA	Australia	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.371+02	\N
at	aut	040	AUSTRIA	Austria	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.371+02	\N
az	aze	031	AZERBAIJAN	Azerbaijan	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.371+02	\N
bs	bhs	044	BAHAMAS	Bahamas	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
bh	bhr	048	BAHRAIN	Bahrain	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
bd	bgd	050	BANGLADESH	Bangladesh	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
bb	brb	052	BARBADOS	Barbados	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.371+02	\N
by	blr	112	BELARUS	Belarus	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
be	bel	056	BELGIUM	Belgium	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
bz	blz	084	BELIZE	Belize	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
bj	ben	204	BENIN	Benin	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
bm	bmu	060	BERMUDA	Bermuda	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
bt	btn	064	BHUTAN	Bhutan	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
bo	bol	068	BOLIVIA	Bolivia	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
bq	bes	535	BONAIRE, SINT EUSTATIUS AND SABA	Bonaire, Sint Eustatius and Saba	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
ba	bih	070	BOSNIA AND HERZEGOVINA	Bosnia and Herzegovina	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.371+02	\N
bw	bwa	072	BOTSWANA	Botswana	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
bv	bvd	074	BOUVET ISLAND	Bouvet Island	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
br	bra	076	BRAZIL	Brazil	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
io	iot	086	BRITISH INDIAN OCEAN TERRITORY	British Indian Ocean Territory	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.373+02	\N
bn	brn	096	BRUNEI DARUSSALAM	Brunei Darussalam	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
bg	bgr	100	BULGARIA	Bulgaria	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
bf	bfa	854	BURKINA FASO	Burkina Faso	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
bi	bdi	108	BURUNDI	Burundi	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
kh	khm	116	CAMBODIA	Cambodia	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.373+02	\N
cm	cmr	120	CAMEROON	Cameroon	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
ca	can	124	CANADA	Canada	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
cv	cpv	132	CAPE VERDE	Cape Verde	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.373+02	\N
ky	cym	136	CAYMAN ISLANDS	Cayman Islands	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.373+02	\N
cf	caf	140	CENTRAL AFRICAN REPUBLIC	Central African Republic	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
td	tcd	148	CHAD	Chad	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.373+02	\N
cl	chl	152	CHILE	Chile	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
cn	chn	156	CHINA	China	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
cx	cxr	162	CHRISTMAS ISLAND	Christmas Island	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.373+02	\N
cc	cck	166	COCOS (KEELING) ISLANDS	Cocos (Keeling) Islands	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
co	col	170	COLOMBIA	Colombia	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.373+02	\N
km	com	174	COMOROS	Comoros	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.373+02	\N
cg	cog	178	CONGO	Congo	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	\N	2026-05-24 12:23:06.683+02	2026-05-28 21:24:33.372+02	\N
\.


--
-- Data for Name: region_payment_provider; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.region_payment_provider (region_id, payment_provider_id, id, created_at, updated_at, deleted_at) FROM stdin;
reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	pp_system_default	regpp_01KT721A17TV4PS1TGR8VBH790	2026-06-03 17:35:08.115828+02	2026-06-03 17:35:08.115828+02	\N
reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	pp_stripe_stripe	regpp_01KT721A1CBCVNMSG9M60G5YDE	2026-06-03 17:35:08.126731+02	2026-06-03 17:35:08.126731+02	\N
reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	pp_kashflow_kashflow	regpp_01KT721A1G5XVKD2P1WAB4MNZ0	2026-06-03 17:35:08.129811+02	2026-06-03 17:35:08.129811+02	\N
\.


--
-- Data for Name: reservation_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reservation_item (id, created_at, updated_at, deleted_at, line_item_id, location_id, quantity, external_id, description, created_by, metadata, inventory_item_id, allow_backorder, raw_quantity) FROM stdin;
resitem_01KSWZ94V60KQ3V81X9WMMJ10W	2026-05-30 19:35:32.22+02	2026-05-31 09:57:18.334+02	2026-05-31 09:57:18.325+02	ordli_01KSWZ94QMZSFYTT7W2RETNS1N	sloc_01KSF7CHXY413KMNRYZAE8PT2S	1	\N	\N	\N	\N	iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	f	{"value": "1", "precision": 20}
resitem_01KSYNR3GJ1SSTSNW9Z3BE5WGV	2026-05-31 11:27:25.461+02	2026-05-31 11:27:52.783+02	2026-05-31 11:27:52.78+02	ordli_01KSYNR3FRS9WA22GY059T0G28	sloc_01KSF7CHXY413KMNRYZAE8PT2S	1	\N	\N	\N	\N	iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	f	{"value": "1", "precision": 20}
resitem_01KSYPW2T2T1S2XY73F6127DCS	2026-05-31 11:47:04.389+02	2026-05-31 11:47:27.627+02	2026-05-31 11:47:27.622+02	ordli_01KSYPW2RSYNTHG25MJ844X3J6	sloc_01KSF7CHXY413KMNRYZAE8PT2S	3	\N	\N	\N	\N	iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	f	{"value": "3", "precision": 20}
resitem_01KSYZ529S48C09WF4ZMX6VWAT	2026-05-31 14:11:47.389+02	2026-05-31 14:11:47.389+02	\N	ordli_01KSYZ528K7F7FE3YWG6T7C8QP	sloc_01KSF7CHXY413KMNRYZAE8PT2S	1	\N	\N	\N	\N	iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	f	{"value": "1", "precision": 20}
resitem_01KSYZ9NMRMPR0XMZS75TBHFY0	2026-05-31 14:14:18.267+02	2026-05-31 14:14:18.267+02	\N	ordli_01KSYZ9NKPT3BD4SADFGXJ2HTE	sloc_01KSF7CHXY413KMNRYZAE8PT2S	1	\N	\N	\N	\N	iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	f	{"value": "1", "precision": 20}
resitem_01KSYZEHCNSXD5AX228S7ZJ2QX	2026-05-31 14:16:57.752+02	2026-05-31 14:16:57.752+02	\N	ordli_01KSYZEHBK57K0417M8YF43A9Q	sloc_01KSF7CHXY413KMNRYZAE8PT2S	2	\N	\N	\N	\N	iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	f	{"value": "2", "precision": 20}
resitem_01KSZ025CRTQHZPT5R952D8T76	2026-05-31 14:27:40.828+02	2026-05-31 14:27:40.828+02	\N	ordli_01KSZ025AV3349EXAY89T9HR6J	sloc_01KSF7CHXY413KMNRYZAE8PT2S	1	\N	\N	\N	\N	iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	f	{"value": "1", "precision": 20}
resitem_01KSZ040RV7DSQ44YRSA5AAP8Q	2026-05-31 14:28:41.633+02	2026-05-31 14:28:41.633+02	\N	ordli_01KSZ040QHCMZVEYMKNPVQSEJD	sloc_01KSF7CHXY413KMNRYZAE8PT2S	1	\N	\N	\N	\N	iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	f	{"value": "1", "precision": 20}
resitem_01KSZ0VB2B1JXRNX87QP25ZWP8	2026-05-31 14:41:25.839+02	2026-05-31 14:41:25.839+02	\N	ordli_01KSZ0VB1ADYXBFHF741VN7QWR	sloc_01KSF7CHXY413KMNRYZAE8PT2S	1	\N	\N	\N	\N	iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	f	{"value": "1", "precision": 20}
resitem_01KZSRKT43CR25F3NENBPRFQ25	2026-08-12 03:15:29.293+02	2026-08-12 03:15:29.293+02	\N	ordli_01KZSRKT0TR6NSR1DY6XMVSJ9H	sloc_01KSF7CHXY413KMNRYZAE8PT2S	1	\N	\N	\N	\N	iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	f	{"value": "1", "precision": 20}
resitem_01KZSRPGXD227ZYBMDMCMXVA3V	2026-08-12 03:16:58.17+02	2026-08-12 03:16:58.17+02	\N	ordli_01KZSRPGT910TWMA1C33G9CGSG	sloc_01KSF7CHXY413KMNRYZAE8PT2S	2	\N	\N	\N	\N	iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	f	{"value": "2", "precision": 20}
resitem_01KZSRT97DWY38DP8W6Y4RXD6P	2026-08-12 03:19:01.37+02	2026-08-12 03:19:01.37+02	\N	ordli_01KZSRT94PSJ2JMJCPVAVGRRXW	sloc_01KSF7CHXY413KMNRYZAE8PT2S	1	\N	\N	\N	\N	iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	f	{"value": "1", "precision": 20}
resitem_01KZSS4E3VXC83YGWDT6JKA9KQ	2026-08-12 03:24:34.054+02	2026-08-12 03:24:34.054+02	\N	ordli_01KZSS4E0JRWCSEPV6GEEPV1E7	sloc_01KSF7CHXY413KMNRYZAE8PT2S	3	\N	\N	\N	\N	iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	f	{"value": "3", "precision": 20}
resitem_01KZSS716ND6Z0ZNJPB4YNB1QN	2026-08-12 03:25:59.139+02	2026-08-12 03:25:59.139+02	\N	ordli_01KZSS713NAAN48S2BJ9EE2KXR	sloc_01KSF7CHXY413KMNRYZAE8PT2S	4	\N	\N	\N	\N	iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	f	{"value": "4", "precision": 20}
resitem_01KZTFBQWMT7C24E0RRR432AQA	2026-08-12 09:53:02.109+02	2026-08-12 09:53:02.109+02	\N	ordli_01KZTFBQSQQ30XNDNFFXPEPV63	sloc_01KSF7CHXY413KMNRYZAE8PT2S	1	\N	\N	\N	\N	iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	f	{"value": "1", "precision": 20}
\.


--
-- Data for Name: return; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.return (id, order_id, claim_id, exchange_id, order_version, display_id, status, no_notification, refund_amount, raw_refund_amount, metadata, created_at, updated_at, deleted_at, received_at, canceled_at, location_id, requested_at, created_by) FROM stdin;
\.


--
-- Data for Name: return_fulfillment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.return_fulfillment (return_id, fulfillment_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: return_item; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.return_item (id, return_id, reason_id, item_id, quantity, raw_quantity, received_quantity, raw_received_quantity, note, metadata, created_at, updated_at, deleted_at, damaged_quantity, raw_damaged_quantity) FROM stdin;
\.


--
-- Data for Name: return_reason; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.return_reason (id, value, label, description, metadata, parent_return_reason_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: review; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.review (id, product_id, customer_id, rating, content, created_at, updated_at, deleted_at, images) FROM stdin;
01KTEDDA6QZ1PC9D4NF4H10JMD	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	cus_01KSR173ECD4A2AJF6H3R1H2J8	3	Bonjour	2026-06-06 14:09:34.167+02	2026-06-06 14:09:34.167+02	\N	\N
01KZV1WQH264KMJ76DX1EWFWHE	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	cus_01KZSMAT6WFYWBGMFDGBSQVMKG	5	Great product, love it!	2026-08-12 15:16:53.154+02	2026-08-12 15:16:53.154+02	\N	["https://s3.eastmarket.africa/eastmarket/test_review-01KZV1W4P2JGEQC9FZCPXEXAM0.png"]
\.


--
-- Data for Name: sales_channel; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sales_channel (id, name, description, is_disabled, metadata, created_at, updated_at, deleted_at) FROM stdin;
sc_01KSCR9E3HDNX82KGM4FXZDGP1	Default Sales Channel	Created by Medusa	f	\N	2026-05-24 12:25:30.737+02	2026-05-24 12:25:30.737+02	\N
\.


--
-- Data for Name: sales_channel_stock_location; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sales_channel_stock_location (sales_channel_id, stock_location_id, id, created_at, updated_at, deleted_at) FROM stdin;
sc_01KSCR9E3HDNX82KGM4FXZDGP1	sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	scloc_01KSCR9E9B568Q1S4H3HZENDEH	2026-05-24 12:25:30.923577+02	2026-05-30 15:30:55.174+02	2026-05-30 15:30:55.173+02
sc_01KSCR9E3HDNX82KGM4FXZDGP1	sloc_01KSF7CHXY413KMNRYZAE8PT2S	scloc_01KSWK0WJ667ZS0MTZZ3K3KBZZ	2026-05-30 19:32:31.985386+02	2026-05-30 19:32:31.985386+02	\N
\.


--
-- Data for Name: script_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.script_migrations (id, script_name, created_at, finished_at) FROM stdin;
1	migrate-product-shipping-profile.js	2026-05-24 12:23:07.188232+02	2026-05-24 12:23:07.210974+02
2	migrate-tax-region-provider.js	2026-05-24 12:23:07.212871+02	2026-05-24 12:23:07.217854+02
\.


--
-- Data for Name: service_zone; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.service_zone (id, name, metadata, fulfillment_set_id, created_at, updated_at, deleted_at) FROM stdin;
serzo_01KSR2WQXBTFJMZ166JTCS1TZD	East	\N	fuset_01KSR2W2CKBZ3D4B3MB4Y2606S	2026-05-28 22:02:27.883+02	2026-05-28 22:02:27.883+02	\N
serzo_01KSCR9E7DM0H9XA9Y3A0H2YXP	Europe	\N	fuset_01KSCR9E7DBG6TWATM3CH2T54A	2026-05-24 12:25:30.861+02	2026-05-30 15:30:55.194+02	2026-05-30 15:30:55.183+02
serzo_01KSWJYMRZEWVVA94TM05N3RSQ	Eas	\N	fuset_01KSWJXMT5RA51MF8N6AK4SGNJ	2026-05-30 16:00:05.151+02	2026-05-30 16:00:05.151+02	\N
\.


--
-- Data for Name: shipping_option; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.shipping_option (id, name, price_type, service_zone_id, shipping_profile_id, provider_id, data, metadata, shipping_option_type_id, created_at, updated_at, deleted_at) FROM stdin;
so_01KSCR9E8AJR7WCCW9B23V79G3	Standard Shipping	flat	serzo_01KSCR9E7DM0H9XA9Y3A0H2YXP	sp_01KSCR9E7ATTZKDD71J1GAA2V8	manual_manual	\N	\N	sotype_01KSCR9E89781PFZZ2QE944HDA	2026-05-24 12:25:30.891+02	2026-05-30 15:30:55.209+02	2026-05-30 15:30:55.183+02
so_01KSCR9E8AR7SRWSCHWPX5G8CH	Express Shipping	flat	serzo_01KSCR9E7DM0H9XA9Y3A0H2YXP	sp_01KSCR9E7ATTZKDD71J1GAA2V8	manual_manual	\N	\N	sotype_01KSCR9E8AH9JNXPKP0QXCPGRT	2026-05-24 12:25:30.891+02	2026-05-30 15:30:55.209+02	2026-05-30 15:30:55.183+02
so_01KSWJDGA032BC8DXPXKW2VX9M	Prince Lulinda Crespo	flat	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	sp_01KSCR51Y68N200HV70RYQZGR2	delivery-company-provider_delivery-company-provider	{"id": "standard-delivery", "is_active": true}	\N	sotype_01KSCR9E89781PFZZ2QE944HDA	2026-05-30 15:50:43.521+02	2026-06-04 16:02:08.93+02	2026-06-04 16:02:08.927+02
so_01KSWJKRYYE6JYE2NV8GVAX0VR	standart	flat	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	sp_01KSCR51Y68N200HV70RYQZGR2	delivery-company-provider_delivery-company-provider	{"id": "standard-delivery", "is_active": true}	\N	sotype_01KSCR9E8AH9JNXPKP0QXCPGRT	2026-05-30 15:54:08.99+02	2026-06-04 16:02:26.919+02	2026-06-04 16:02:26.918+02
so_01KSWK0MGHVTE3D3GG9BEB4SYS	LV1	flat	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	sp_01KSCR51Y68N200HV70RYQZGR2	delivery-company-provider_delivery-company-provider	{"id": "standard-delivery", "is_active": true}	\N	sotype_01KSCR9E89781PFZZ2QE944HDA	2026-05-30 16:01:10.417+02	2026-06-05 00:30:54.354+02	2026-06-05 00:30:54.353+02
so_01KT9F4RGG3QH9TJK4RK3B94HP	express	flat	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	sp_01KSCR51Y68N200HV70RYQZGR2	delivery-company-provider_delivery-company-provider	{"id": "standard-delivery", "is_active": true}	\N	sotype_01KSCR9E8AH9JNXPKP0QXCPGRT	2026-06-04 16:03:38.896+02	2026-06-05 00:32:47.327+02	2026-06-05 00:32:47.326+02
so_01KTAC4W5KSP7M868818GXGN8V	Express	flat	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	sp_01KSCR51Y68N200HV70RYQZGR2	delivery-company-provider_delivery-company-provider	{"id": "standard-delivery", "is_active": true}	\N	sotype_01KSCR9E8AH9JNXPKP0QXCPGRT	2026-06-05 00:30:31.348+02	2026-06-05 00:35:51.941+02	2026-06-05 00:35:51.94+02
so_01KTACAPY11NEFCAQ1Z79W7DXP	Express	flat	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	sp_01KSCR51Y68N200HV70RYQZGR2	delivery-company-provider_delivery-company-provider	{"id": "standard-delivery", "is_active": true}	\N	sotype_01KSCR9E89781PFZZ2QE944HDA	2026-06-05 00:33:42.594+02	2026-06-05 00:35:59.48+02	2026-06-05 00:35:59.479+02
so_01KTACDA0EX08JWS75B4SW1BDG	Express	flat	serzo_01KSR2WQXBTFJMZ166JTCS1TZD	sp_01KSCR51Y68N200HV70RYQZGR2	delivery-company-provider_delivery-company-provider	{"id": "standard-delivery", "is_active": true}	\N	sotype_01KSCR9E8AH9JNXPKP0QXCPGRT	2026-06-05 00:35:07.663+02	2026-06-05 01:21:39.839+02	2026-06-05 01:21:39.837+02
so_01KTAF58PA2C6DZQG2GAR40V2H	express	flat	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	sp_01KSCR51Y68N200HV70RYQZGR2	delivery-company-provider_delivery-company-provider	{"id": "standard-delivery", "is_active": true}	\N	sotype_01KSCR9E8AH9JNXPKP0QXCPGRT	2026-06-05 01:23:09.899+02	2026-06-05 01:23:09.899+02	\N
so_01KTAFNNF59QWDVTRF6X6WJ9RG	Standart	flat	serzo_01KSWJYMRZEWVVA94TM05N3RSQ	sp_01KSCR51Y68N200HV70RYQZGR2	delivery-company-provider_delivery-company-provider	{"id": "standard-delivery", "is_active": true}	\N	sotype_01KSCR9E89781PFZZ2QE944HDA	2026-06-05 01:32:07.269+02	2026-06-05 01:32:07.269+02	\N
\.


--
-- Data for Name: shipping_option_price_set; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.shipping_option_price_set (shipping_option_id, price_set_id, id, created_at, updated_at, deleted_at) FROM stdin;
so_01KSCR9E8AJR7WCCW9B23V79G3	pset_01KSCR9E8SESZKQR1E3J6NBEQ4	sops_01KSCR9E97J4KZSZ8KHVM1TXRY	2026-05-24 12:25:30.919416+02	2026-05-30 15:30:55.241+02	2026-05-30 15:30:55.24+02
so_01KSCR9E8AR7SRWSCHWPX5G8CH	pset_01KSCR9E8SQ6D9GFMMRAVSVXWW	sops_01KSCR9E97QHMJF249MQHZ7MSE	2026-05-24 12:25:30.919416+02	2026-05-30 15:30:55.241+02	2026-05-30 15:30:55.24+02
so_01KSWJDGA032BC8DXPXKW2VX9M	pset_01KSWJDGAHMXYPTTQECENVHTV8	sops_01KSWJDGB8J638R9ZASPEWA98X	2026-05-30 15:50:43.559433+02	2026-06-04 16:02:08.979+02	2026-06-04 16:02:08.977+02
so_01KSWJKRYYE6JYE2NV8GVAX0VR	pset_01KSWJKRZDQT4ANWVMWG7DH9C6	sops_01KSWJKS023X9AFC3JWNZHVV9S	2026-05-30 15:54:09.026024+02	2026-06-04 16:02:26.942+02	2026-06-04 16:02:26.942+02
so_01KSWK0MGHVTE3D3GG9BEB4SYS	pset_01KSWK0MH7VR7YCT2VPRBGFNF3	sops_01KSWK0MJH8676T18Y3K317A93	2026-05-30 16:01:10.480481+02	2026-06-05 00:30:54.384+02	2026-06-05 00:30:54.383+02
so_01KT9F4RGG3QH9TJK4RK3B94HP	pset_01KT9F4RHCQPK7AMGXDXC9VYSZ	sops_01KT9F4RJ5EWKNTPSHF7H582FB	2026-06-04 16:03:38.948248+02	2026-06-05 00:32:47.347+02	2026-06-05 00:32:47.346+02
so_01KTAC4W5KSP7M868818GXGN8V	pset_01KTAC4W6AE91XR91GSTBWTHBY	sops_01KTAC4W7E2KFTYA0TY9PGH4MR	2026-06-05 00:30:31.40572+02	2026-06-05 00:35:51.958+02	2026-06-05 00:35:51.957+02
so_01KTACAPY11NEFCAQ1Z79W7DXP	pset_01KTACAPYHJ6PBPR81CB08Z82K	sops_01KTACAPZ7YMJ9MYE44G0M0X9D	2026-06-05 00:33:42.631349+02	2026-06-05 00:35:59.508+02	2026-06-05 00:35:59.507+02
so_01KTACDA0EX08JWS75B4SW1BDG	pset_01KTACDA0YWCM9QJKHQ58PWEK3	sops_01KTACDA1R8CBNXHTBB0C0X7NV	2026-06-05 00:35:07.703573+02	2026-06-05 01:21:39.865+02	2026-06-05 01:21:39.864+02
so_01KTAF58PA2C6DZQG2GAR40V2H	pset_01KTAF58QBQAPD4Q3FSYKHBBD6	sops_01KTAF58QQK63CXYBMZGTWCFCR	2026-06-05 01:23:09.942863+02	2026-06-05 01:23:09.942863+02	\N
so_01KTAFNNF59QWDVTRF6X6WJ9RG	pset_01KTAFNNFF6EBWH2CQAKAKSRDK	sops_01KTAFNNFWCXA2AV6TSJ1KR731	2026-06-05 01:32:07.291768+02	2026-06-05 01:32:07.291768+02	\N
\.


--
-- Data for Name: shipping_option_rule; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.shipping_option_rule (id, attribute, operator, value, shipping_option_id, created_at, updated_at, deleted_at) FROM stdin;
sorul_01KSCR9E8A44NE4EFD1JW0P817	enabled_in_store	eq	"true"	so_01KSCR9E8AJR7WCCW9B23V79G3	2026-05-24 12:25:30.891+02	2026-05-30 15:30:55.226+02	2026-05-30 15:30:55.183+02
sorul_01KSCR9E8AYFR5F7YC8ZWDEBVB	is_return	eq	"false"	so_01KSCR9E8AJR7WCCW9B23V79G3	2026-05-24 12:25:30.891+02	2026-05-30 15:30:55.226+02	2026-05-30 15:30:55.183+02
sorul_01KSCR9E8AX1K315F4319WVPX5	enabled_in_store	eq	"\\"true\\""	so_01KSCR9E8AR7SRWSCHWPX5G8CH	2026-05-24 12:25:30.891+02	2026-05-30 15:30:55.226+02	2026-05-30 15:30:55.183+02
sorul_01KSCR9E8AKZ3N1A2DB81X74YR	is_return	eq	"false"	so_01KSCR9E8AR7SRWSCHWPX5G8CH	2026-05-24 12:25:30.891+02	2026-05-30 15:30:55.226+02	2026-05-30 15:30:55.183+02
sorul_01KSWJDGA0C3B73K6E0TX5PGJB	is_return	eq	"false"	so_01KSWJDGA032BC8DXPXKW2VX9M	2026-05-30 15:50:43.521+02	2026-06-04 16:02:08.961+02	2026-06-04 16:02:08.927+02
sorul_01KSWJDGA0636BJE5FB0F5CT3Q	enabled_in_store	eq	"true"	so_01KSWJDGA032BC8DXPXKW2VX9M	2026-05-30 15:50:43.522+02	2026-06-04 16:02:08.961+02	2026-06-04 16:02:08.927+02
sorul_01KSWJKRYY93P05EHB40NZZXGY	is_return	eq	"false"	so_01KSWJKRYYE6JYE2NV8GVAX0VR	2026-05-30 15:54:08.991+02	2026-06-04 16:02:26.929+02	2026-06-04 16:02:26.918+02
sorul_01KSWJKRYY1KSFPK0NCK0KAFP8	enabled_in_store	eq	"true"	so_01KSWJKRYYE6JYE2NV8GVAX0VR	2026-05-30 15:54:08.991+02	2026-06-04 16:02:26.929+02	2026-06-04 16:02:26.918+02
sorul_01KSWK0MGGNDHWXGVPJ8KSC6XY	is_return	eq	"false"	so_01KSWK0MGHVTE3D3GG9BEB4SYS	2026-05-30 16:01:10.417+02	2026-06-05 00:30:54.364+02	2026-06-05 00:30:54.353+02
sorul_01KSWK0MGHCECRWKW8GGPP5K7G	enabled_in_store	eq	"true"	so_01KSWK0MGHVTE3D3GG9BEB4SYS	2026-05-30 16:01:10.418+02	2026-06-05 00:30:54.364+02	2026-06-05 00:30:54.353+02
sorul_01KT9F4RGFWYVXYTNT8QHZAVC6	is_return	eq	"false"	so_01KT9F4RGG3QH9TJK4RK3B94HP	2026-06-04 16:03:38.897+02	2026-06-05 00:32:47.336+02	2026-06-05 00:32:47.326+02
sorul_01KT9F4RGGVRXV27RK6ZKQG6WZ	enabled_in_store	eq	"true"	so_01KT9F4RGG3QH9TJK4RK3B94HP	2026-06-04 16:03:38.897+02	2026-06-05 00:32:47.336+02	2026-06-05 00:32:47.326+02
sorul_01KTAC4W5KQQ1A6VH42HMAJ34G	is_return	eq	"false"	so_01KTAC4W5KSP7M868818GXGN8V	2026-06-05 00:30:31.35+02	2026-06-05 00:35:51.95+02	2026-06-05 00:35:51.94+02
sorul_01KTAC4W5KZFP1FE6666M0D48Q	enabled_in_store	eq	"true"	so_01KTAC4W5KSP7M868818GXGN8V	2026-06-05 00:30:31.35+02	2026-06-05 00:35:51.95+02	2026-06-05 00:35:51.94+02
sorul_01KTACAPY126VTQAYVMCFA2KCH	is_return	eq	"false"	so_01KTACAPY11NEFCAQ1Z79W7DXP	2026-06-05 00:33:42.594+02	2026-06-05 00:35:59.488+02	2026-06-05 00:35:59.479+02
sorul_01KTACAPY1DT5939SF582VD60P	enabled_in_store	eq	"true"	so_01KTACAPY11NEFCAQ1Z79W7DXP	2026-06-05 00:33:42.594+02	2026-06-05 00:35:59.489+02	2026-06-05 00:35:59.479+02
sorul_01KTACDA0ENWPXEJ244EW566YQ	is_return	eq	"false"	so_01KTACDA0EX08JWS75B4SW1BDG	2026-06-05 00:35:07.663+02	2026-06-05 01:21:39.85+02	2026-06-05 01:21:39.837+02
sorul_01KTACDA0EW9Y9YAT2T0SEXJCB	enabled_in_store	eq	"true"	so_01KTACDA0EX08JWS75B4SW1BDG	2026-06-05 00:35:07.663+02	2026-06-05 01:21:39.85+02	2026-06-05 01:21:39.837+02
sorul_01KTAF58PA7K754TH668NSNKES	is_return	eq	"false"	so_01KTAF58PA2C6DZQG2GAR40V2H	2026-06-05 01:23:09.899+02	2026-06-05 01:23:09.899+02	\N
sorul_01KTAF58PACG9R3CXZCDJVYC51	enabled_in_store	eq	"true"	so_01KTAF58PA2C6DZQG2GAR40V2H	2026-06-05 01:23:09.899+02	2026-06-05 01:23:09.899+02	\N
sorul_01KTAFNNF4Z5NEVJGSXRFZABWK	is_return	eq	"false"	so_01KTAFNNF59QWDVTRF6X6WJ9RG	2026-06-05 01:32:07.269+02	2026-06-05 01:32:07.269+02	\N
sorul_01KTAFNNF5WA257VF79H5QJ1QD	enabled_in_store	eq	"true"	so_01KTAFNNF59QWDVTRF6X6WJ9RG	2026-06-05 01:32:07.269+02	2026-06-05 01:32:07.269+02	\N
\.


--
-- Data for Name: shipping_option_type; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.shipping_option_type (id, label, description, code, created_at, updated_at, deleted_at) FROM stdin;
sotype_01KSCR9E89781PFZZ2QE944HDA	Standard	Ship in 2-3 days.	standard	2026-05-24 12:25:30.891+02	2026-05-24 12:25:30.891+02	\N
sotype_01KSCR9E8AH9JNXPKP0QXCPGRT	Express	Ship in 24 hours.	express	2026-05-24 12:25:30.891+02	2026-05-24 12:25:30.891+02	\N
sotype_01KSR239149JMBYDWQS4JS9SZW	AVIo	Withdrawal request of 136.5 USDT on BEP20 to 0xe036498A99DE89E4b9d58AB8Dd5E5521a85E548E	avio	2026-05-28 21:48:33.444+02	2026-05-28 21:48:33.444+02	\N
\.


--
-- Data for Name: shipping_profile; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.shipping_profile (id, name, type, metadata, created_at, updated_at, deleted_at) FROM stdin;
sp_01KSCR51Y68N200HV70RYQZGR2	Default Shipping Profile	default	\N	2026-05-24 12:23:07.206+02	2026-05-24 12:23:07.207+02	\N
sp_01KSCR9E7ATTZKDD71J1GAA2V8	Default	default	\N	2026-05-24 12:25:30.858+02	2026-05-24 12:25:30.858+02	\N
\.


--
-- Data for Name: short_video; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.short_video (id, vendor_id, title, description, video_url, thumbnail_url, duration, tag, status, likes_count, comments_count, shares_count, views_count, product_ids, created_at, updated_at, deleted_at, hls_url, is_processed) FROM stdin;
01KSGXZM829KSFJ5XEK7DWDXPD	01KSCSTSPDSEAN744XV198F4RD	Sufuria		http://localhost:9000/static/1779758518453-video_1779758510432.mp4	\N	\N	mode	draft	0	0	0	0	[]	2026-05-26 03:21:58.531+02	2026-05-26 03:21:58.531+02	\N	\N	f
01KSH26CPAQVDWTFSNAPRDW8X7	01KSCSTSPDSEAN744XV198F4RD	Video		http://localhost:9000/static/1779762934422-video_1779762931797.mp4	\N	\N	mode	draft	0	0	0	0	[]	2026-05-26 04:35:34.475+02	2026-05-26 04:35:34.475+02	\N	\N	f
01KSH2BJJWRBMTPQSNXWDHBTD7	01KSCSTSPDSEAN744XV198F4RD	Suffu		http://localhost:9000/static/1779763104308-video_1779763101636.mp4	\N	\N	mode	draft	0	0	0	0	["prod_01KSH2A8YPQ2M4AN368YBJ9X3C"]	2026-05-26 04:38:24.348+02	2026-05-26 04:38:24.348+02	\N	\N	f
01KSR791WK87NN23RVZXDB516T	01KSCSTSPDSEAN744XV198F4RD	Air force		http://localhost:9000/static/1780003145552-video_1780003142807.mp4	\N	\N	mode	draft	0	0	0	0	[]	2026-05-28 23:19:05.62+02	2026-05-28 23:19:05.62+02	\N	\N	f
01KSR7NSZJ1E8MV1WN1Z03VYFF	01KSCSTSPDSEAN744XV198F4RD	Fan		http://localhost:9000/static/1780003563370-video_1780003550371.mp4	\N	\N	mode	draft	0	0	0	0	[]	2026-05-28 23:26:03.506+02	2026-05-28 23:26:03.506+02	\N	\N	f
01KSR7YZHRNBTXNSS66ZSCWM6Q	01KSCSTSPDSEAN744XV198F4RD	Draps		http://localhost:9000/static/1780003864048-video_1780003862295.mp4	\N	\N	mode	draft	0	0	0	0	[]	2026-05-28 23:31:04.121+02	2026-05-28 23:31:04.121+02	\N	\N	f
01KSR81Y31HX61RYYJQNBF7JRH	01KSCSTSPDSEAN744XV198F4RD	Draps		http://localhost:9000/static/1780003960864-video_1780003958569.mp4	\N	\N	mode	draft	0	0	0	0	[]	2026-05-28 23:32:40.929+02	2026-05-28 23:32:40.929+02	\N	\N	f
01KSR84AC08MCR1K7R384A2VEC	01KSCSTSPDSEAN744XV198F4RD	Draps		http://localhost:9000/static/1780004038969-video_1780004037153.mp4	\N	\N	mode	draft	0	0	0	0	[]	2026-05-28 23:33:59.04+02	2026-05-28 23:33:59.04+02	\N	\N	f
01KSR86Q1FH4GZGWWZN0P8MQNV	01KSCSTSPDSEAN744XV198F4RD	Draps		http://localhost:9000/static/1780004117441-video_1780004115254.mp4	\N	\N	mode	draft	0	0	0	0	[]	2026-05-28 23:35:17.551+02	2026-05-28 23:35:17.551+02	\N	\N	f
01KSR86Q3SM6GYMRZSJW7JN01G	01KSCSTSPDSEAN744XV198F4RD	Draps		http://localhost:9000/static/1780004117581-video_1780004115354.mp4	\N	\N	mode	draft	0	0	0	0	[]	2026-05-28 23:35:17.625+02	2026-05-28 23:35:17.625+02	\N	\N	f
01KSR97J0XYGBP8TMZN2DFQAJ9	01KSCSTSPDSEAN744XV198F4RD	Draps le		http://localhost:9000/static/1780005193611-video_1780005191657.mp4	\N	\N	mode	draft	0	0	0	0	[]	2026-05-28 23:53:13.758+02	2026-05-28 23:53:13.758+02	\N	\N	f
01KSR9NEJYVWGSKEDYV47QD92D	01KSCSTSP7N25SPSF2H5AK45FY	Masani		http://localhost:9000/static/1780005648920-video_1780005646717.mp4	\N	\N	mode	draft	0	0	0	0	[]	2026-05-29 00:00:48.991+02	2026-05-29 00:00:48.991+02	\N	\N	f
01KSRAVHC730ATN8739JEA6M8B	01KSCSTSP7N25SPSF2H5AK45FY	Saani		http://localhost:9000/static/1780006896891-video_1780006888735.mp4	\N	\N	mode	draft	0	0	0	0	[]	2026-05-29 00:21:37.032+02	2026-05-29 00:21:37.032+02	\N	\N	f
01KV5D881Y13B5R93K3KSVS0RC	01KV5CHYWYZVSNYGB0RXEYG5CK	Vidéo Sandale		https://s3.eastmarket.africa/eastmarket/video_1781519344014-01KV5D7Z2Q3DHMCYBT75X8NR36.mp4	\N	\N	produit	published	1	0	0	35	["prod_01KV5D7S5A3GT3TNV6JJ36QA88"]	2026-06-15 12:29:20.063+02	2026-08-15 20:42:38.402+02	\N	https://s3.eastmarket.africa/eastmarket/video_1781519344014-01KV5D7Z2Q3DHMCYBT75X8NR36.mp4	f
01KSRBXKRZRKXFAZK6VWV2WNBW	01KSCSTSP7N25SPSF2H5AK45FY	Saani		http://localhost:9000/static/1780008013464-video_1780008011454.mp4	\N	\N	mode	published	1	3	0	117	["prod_01KSH2A8YPQ2M4AN368YBJ9X3C"]	2026-05-29 00:40:13.6+02	2026-08-15 20:42:14.415+02	\N	http://localhost:9000/static/1780008013464-video_1780008011454.mp4	f
01KSRBWX4WCXHWPJ5AM9C54AS2	01KSCSTSP7N25SPSF2H5AK45FY	Hot pot		http://localhost:9000/static/1780007990218-video_1780007983538.mp4	\N	\N	mode	published	2	0	0	92	[]	2026-05-29 00:39:50.428+02	2026-08-15 20:42:16.719+02	\N	http://localhost:9000/static/1780007990218-video_1780007983538.mp4	f
01KSRB09F12K4PY852ZDN2R3MQ	01KSCSTSP7N25SPSF2H5AK45FY	Glasses		http://localhost:9000/static/1780007052610-video_1780007044686.mp4	\N	\N	mode	published	1	0	5	64	[]	2026-05-29 00:24:12.769+02	2026-08-15 20:42:21.104+02	\N	http://localhost:9000/static/1780007052610-video_1780007044686.mp4	f
01KT1579P8KXJYXZR33E8D7H5A	01KSDE9JVTNAXE0NF67DNVEWBS	Vidéo Mapapa		http://localhost:9000/static/1780302980618-video_1780302965198.mp4	\N	\N	produit	published	0	0	0	59	["prod_01KT156V00QYP2NS7HYG4BWMYG"]	2026-06-01 10:36:20.809+02	2026-08-15 20:42:25.726+02	\N	http://localhost:9000/static/1780302980618-video_1780302965198.mp4	f
\.


--
-- Data for Name: stock_location; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stock_location (id, created_at, updated_at, deleted_at, name, address_id, metadata) FROM stdin;
sloc_01KSF7CHXY413KMNRYZAE8PT2S	2026-05-25 11:27:50.463+02	2026-05-25 11:27:50.463+02	\N	Bujumbura	laddr_01KSF7CHXYKEWR6G52MKEQ0EGY	\N
sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	2026-05-24 12:25:30.847+02	2026-05-30 15:30:55.135+02	2026-05-30 15:30:55.132+02	European Warehouse	laddr_01KSCR9E6YNQMYK9WRDF27Q1B5	\N
sloc_01KV57VMM76EG8GT7Q0K6YJWNY	2026-06-15 10:55:04.072+02	2026-06-15 10:55:04.072+02	\N	Boutique de musenyi	laddr_01KV57VMM7ZABP1QS4PA70RSSS	\N
sloc_01KV5E2Y7H26Q6TEM5QXJEXXX6	2026-06-15 12:43:54.737+02	2026-06-15 12:43:54.737+02	\N	Tanga shop	laddr_01KV5E2Y7GJP8C52JGZ2QATR59	\N
sloc_01KV6A8VK5MQZ5M0VNTGGF1EZ4	2026-06-15 20:56:28.773+02	2026-06-15 20:56:28.773+02	\N	Tanga chop	laddr_01KV6A8VK5JC8BC43VDBYY8YA7	\N
sloc_01KWSMKZKAD8K1XXWV6EJAZD1F	2026-07-05 19:18:35.115+02	2026-07-05 19:18:35.115+02	\N	Kinama	laddr_01KWSMKZKA58QX1HS3TREVCGA1	\N
\.


--
-- Data for Name: stock_location_address; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stock_location_address (id, created_at, updated_at, deleted_at, address_1, address_2, company, city, country_code, phone, province, postal_code, metadata) FROM stdin;
laddr_01KSF7CHXYKEWR6G52MKEQ0EGY	2026-05-25 11:27:50.462+02	2026-05-25 11:27:50.462+02	\N	10 avenue	\N	\N	Bujumbura	bu	\N	\N	\N	\N
laddr_01KSCR9E6YNQMYK9WRDF27Q1B5	2026-05-24 12:25:30.847+02	2026-05-30 15:30:55.153+02	2026-05-30 15:30:55.132+02		\N	\N	Copenhagen	DK	\N	\N	\N	\N
laddr_01KV57VMM7ZABP1QS4PA70RSSS	2026-06-15 10:55:04.071+02	2026-06-15 10:55:04.071+02	\N	Bujumbura	\N	\N	Bujumbura	bi	\N	\N	\N	\N
laddr_01KV5E2Y7GJP8C52JGZ2QATR59	2026-06-15 12:43:54.737+02	2026-06-15 12:43:54.737+02	\N	T9	\N	\N	Ng'Ambokagango	tz	\N	Kagera	\N	\N
laddr_01KV6A8VK5JC8BC43VDBYY8YA7	2026-06-15 20:56:28.773+02	2026-06-15 20:56:28.773+02	\N	Bujumbura	\N	\N	Bujumbura	bi	\N	Bujumbura Mairie	\N	\N
laddr_01KWSMKZKA58QX1HS3TREVCGA1	2026-07-05 19:18:35.114+02	2026-07-05 19:18:35.114+02	\N	Kinama	\N	\N	Bujumbura	bi	\N	Bujumbura Mairie	\N	\N
\.


--
-- Data for Name: store; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.store (id, name, default_sales_channel_id, default_region_id, default_location_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
store_01KSCR9E3Z2Z3635HXYG0Y2KH4	Eastmarket Store	sc_01KSCR9E3HDNX82KGM4FXZDGP1	\N	\N	\N	2026-05-24 12:25:30.750211+02	2026-05-24 12:25:30.750211+02	\N
\.


--
-- Data for Name: store_currency; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.store_currency (id, currency_code, is_default, store_id, created_at, updated_at, deleted_at) FROM stdin;
stocur_01KWSK8XH0AS5Y2FDFDXA02545	bif	f	store_01KSCR9E3Z2Z3635HXYG0Y2KH4	2026-07-05 18:55:03.951934+02	2026-07-05 18:55:03.951934+02	\N
stocur_01KWSK8XH0JPY1DWKAMVHCKHX4	usd	t	store_01KSCR9E3Z2Z3635HXYG0Y2KH4	2026-07-05 18:55:03.951934+02	2026-07-05 18:55:03.951934+02	\N
\.


--
-- Data for Name: store_locale; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.store_locale (id, locale_code, store_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: tax_provider; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tax_provider (id, is_enabled, created_at, updated_at, deleted_at) FROM stdin;
tp_system	t	2026-05-24 12:23:06.722+02	2026-05-24 12:23:06.722+02	\N
\.


--
-- Data for Name: tax_rate; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tax_rate (id, rate, code, name, is_default, is_combinable, tax_region_id, metadata, created_at, updated_at, created_by, deleted_at) FROM stdin;
\.


--
-- Data for Name: tax_rate_rule; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tax_rate_rule (id, tax_rate_id, reference_id, reference, metadata, created_at, updated_at, created_by, deleted_at) FROM stdin;
\.


--
-- Data for Name: tax_region; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tax_region (id, provider_id, country_code, province_code, parent_id, metadata, created_at, updated_at, created_by, deleted_at) FROM stdin;
txreg_01KSCR9E6KYCD2DA5SMCS5W3NC	tp_system	gb	\N	\N	\N	2026-05-24 12:25:30.837+02	2026-05-24 12:25:30.837+02	\N	\N
txreg_01KSCR9E6M10TWC5M96A7J0SFB	tp_system	de	\N	\N	\N	2026-05-24 12:25:30.837+02	2026-05-24 12:25:30.837+02	\N	\N
txreg_01KSCR9E6MVHG9MFBBPXWZ04NE	tp_system	dk	\N	\N	\N	2026-05-24 12:25:30.837+02	2026-05-24 12:25:30.837+02	\N	\N
txreg_01KSCR9E6M3MX3G5ZANMGTATRZ	tp_system	se	\N	\N	\N	2026-05-24 12:25:30.837+02	2026-05-24 12:25:30.837+02	\N	\N
txreg_01KSCR9E6MEWXRD1390MZ360HT	tp_system	fr	\N	\N	\N	2026-05-24 12:25:30.837+02	2026-05-24 12:25:30.837+02	\N	\N
txreg_01KSCR9E6MVZ20SC4YZK9YCNEQ	tp_system	es	\N	\N	\N	2026-05-24 12:25:30.837+02	2026-05-24 12:25:30.837+02	\N	\N
txreg_01KSCR9E6MD3DR4CRP9QAZ20GY	tp_system	it	\N	\N	\N	2026-05-24 12:25:30.837+02	2026-05-24 12:25:30.837+02	\N	\N
\.


--
-- Data for Name: translation; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.translation (id, reference_id, reference, locale_code, translations, created_at, updated_at, deleted_at, translated_field_count) FROM stdin;
\.


--
-- Data for Name: translation_settings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.translation_settings (id, entity_type, fields, created_at, updated_at, deleted_at, is_active) FROM stdin;
trset_01KTFEHHPG2DF3CDGGV9AK7W1M	shipping_option_type	["label", "description"]	2026-06-06 23:48:35.921+02	2026-06-06 23:48:35.921+02	\N	t
trset_01KTFEHHPG4Q1Z3865VXF27K3E	shipping_option	["name"]	2026-06-06 23:48:35.921+02	2026-06-06 23:48:35.921+02	\N	t
trset_01KTFEHHPG9YFBKV5638PHQ5K2	product_category	["name", "description"]	2026-06-06 23:48:35.921+02	2026-06-06 23:48:35.921+02	\N	t
trset_01KTFEHHPG3BYJHSSNMS08D18E	product_collection	["title"]	2026-06-06 23:48:35.921+02	2026-06-06 23:48:35.921+02	\N	t
trset_01KTFEHHPG9N6Z9EGHC9JRTZM2	product_variant	["title", "material"]	2026-06-06 23:48:35.921+02	2026-06-06 23:48:35.921+02	\N	t
trset_01KTFEHHPGXWC1A6WRPA7JW0NQ	product_option_value	["value"]	2026-06-06 23:48:35.921+02	2026-06-06 23:48:35.921+02	\N	t
trset_01KTFEHHPG7DRC1179158WGZNJ	product_option	["title"]	2026-06-06 23:48:35.921+02	2026-06-06 23:48:35.921+02	\N	t
trset_01KTFEHHPG68CEXAHKRZZ5AFCF	product_tag	["value"]	2026-06-06 23:48:35.921+02	2026-06-06 23:48:35.921+02	\N	t
trset_01KTFEHHPG5MS0RG22J3CS0CXB	product_type	["value"]	2026-06-06 23:48:35.921+02	2026-06-06 23:48:35.921+02	\N	t
trset_01KTFEHHPGBHS351YZY71QCF45	product	["title", "subtitle", "description", "material"]	2026-06-06 23:48:35.921+02	2026-06-06 23:48:35.921+02	\N	t
trset_01KTFEHHPG7WNK0PMX9PZX1GK7	customer_group	["name"]	2026-06-06 23:48:35.921+02	2026-06-06 23:48:35.921+02	\N	t
trset_01KTFEHHPGD4YS6ZAXBN08E9Q3	region	["name"]	2026-06-06 23:48:35.921+02	2026-06-06 23:48:35.921+02	\N	t
trset_01KTFEHHPGVX168YXZXX1FS81Q	tax_rate	["name"]	2026-06-06 23:48:35.921+02	2026-06-06 23:48:35.921+02	\N	t
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."user" (id, first_name, last_name, email, avatar_url, metadata, created_at, updated_at, deleted_at) FROM stdin;
user_01KSCRW542GHYQFHM9FB3QZM2J	\N	\N	princelulinda@gmail.com	\N	\N	2026-05-24 12:35:44.13+02	2026-05-24 12:35:44.13+02	\N
\.


--
-- Data for Name: user_activity; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_activity (id, customer_id, action_type, entity_type, entity_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
01KZVJKM3MPVEQHHHC53RBYTGW	cus_01KZSMAT6WFYWBGMFDGBSQVMKG	product_view	product	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	\N	2026-08-12 20:09:00.533+02	2026-08-12 20:09:00.533+02	\N
01KZVJKM4EE0TM31S21G8FP9TE	cus_01KZSMAT6WFYWBGMFDGBSQVMKG	search	\N	\N	{"query": "sandale"}	2026-08-12 20:09:00.558+02	2026-08-12 20:09:00.558+02	\N
01KZX3CN5Y0Q3AG6JKP876PCF9	cus_01KZV2PTYGTZ4E2VCQ7R28NYVF	product_view	product	prod_01KV5DPWQMJ87E724G2PHS05ZZ	\N	2026-08-13 10:21:32.479+02	2026-08-13 10:21:32.479+02	\N
01KZX3D4NN2GK96Z8NR5ZRAXVW	cus_01KZV2PTYGTZ4E2VCQ7R28NYVF	product_view	product	prod_01KV5H8J0X1ZXZA46EZ0MG683D	\N	2026-08-13 10:21:48.342+02	2026-08-13 10:21:48.342+02	\N
01KZX3RJR1DP9NT9P32HA1ZZGV	cus_01KZV2PTYGTZ4E2VCQ7R28NYVF	product_view	product	prod_01KV5H8J0X1ZXZA46EZ0MG683D	\N	2026-08-13 10:28:03.201+02	2026-08-13 10:28:03.201+02	\N
01KZX3RNA5AMPF8ZT75Z95FBW0	cus_01KZV2PTYGTZ4E2VCQ7R28NYVF	product_view	product	prod_01KV5H8J0X1ZXZA46EZ0MG683D	\N	2026-08-13 10:28:05.829+02	2026-08-13 10:28:05.829+02	\N
01KZX3S72RVH39NZQCWJP1VR21	cus_01KZV2PTYGTZ4E2VCQ7R28NYVF	product_view	product	prod_01KV5H8J0X1ZXZA46EZ0MG683D	\N	2026-08-13 10:28:24.024+02	2026-08-13 10:28:24.024+02	\N
01KZX3TTV9NQ7EPF24B8VZ3EHY	cus_01KZV2PTYGTZ4E2VCQ7R28NYVF	product_view	product	prod_01KV5H8J0X1ZXZA46EZ0MG683D	\N	2026-08-13 10:29:17.033+02	2026-08-13 10:29:17.033+02	\N
01KZX3TXKCBPNJWVF1SZ241N2H	cus_01KZV2PTYGTZ4E2VCQ7R28NYVF	product_view	product	prod_01KV5H8J0X1ZXZA46EZ0MG683D	\N	2026-08-13 10:29:19.852+02	2026-08-13 10:29:19.852+02	\N
01KZX3V585DA59J7G4XYYPEY4N	cus_01KZV2PTYGTZ4E2VCQ7R28NYVF	product_view	product	prod_01KV5H8J0X1ZXZA46EZ0MG683D	\N	2026-08-13 10:29:27.685+02	2026-08-13 10:29:27.685+02	\N
01KZX3V5VCHD2HEJ3WXMQAP63F	cus_01KZV2PTYGTZ4E2VCQ7R28NYVF	product_view	product	prod_01KV5H8J0X1ZXZA46EZ0MG683D	\N	2026-08-13 10:29:28.3+02	2026-08-13 10:29:28.3+02	\N
01KZX3VD4XZFVWWJGTWC8RDSGJ	cus_01KZV2PTYGTZ4E2VCQ7R28NYVF	product_view	product	prod_01KV5H8J0X1ZXZA46EZ0MG683D	\N	2026-08-13 10:29:35.773+02	2026-08-13 10:29:35.773+02	\N
01KZX3VDSRNNSFC1M2YB609J76	cus_01KZV2PTYGTZ4E2VCQ7R28NYVF	product_view	product	prod_01KV5H8J0X1ZXZA46EZ0MG683D	\N	2026-08-13 10:29:36.441+02	2026-08-13 10:29:36.441+02	\N
01KZX3VEZN2H3W27KNSX46GZMX	cus_01KZV2PTYGTZ4E2VCQ7R28NYVF	product_view	product	prod_01KV5H8J0X1ZXZA46EZ0MG683D	\N	2026-08-13 10:29:37.653+02	2026-08-13 10:29:37.653+02	\N
01KZX3VFPN3HW18038YNPC07P0	cus_01KZV2PTYGTZ4E2VCQ7R28NYVF	product_view	product	prod_01KV5H8J0X1ZXZA46EZ0MG683D	\N	2026-08-13 10:29:38.389+02	2026-08-13 10:29:38.389+02	\N
01KZX444B1SK3ZGGGRKQARG1RK	cus_01KZV2PTYGTZ4E2VCQ7R28NYVF	product_view	product	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	\N	2026-08-13 10:34:21.665+02	2026-08-13 10:34:21.665+02	\N
01KZYEDHW5VYYDS9CW7VZWMFE0	cus_01KSR173ECD4A2AJF6H3R1H2J8	product_view	product	prod_01KV5D7S5A3GT3TNV6JJ36QA88	\N	2026-08-13 22:53:30.629+02	2026-08-13 22:53:30.629+02	\N
01KZYEDHW995GCPMDZYHXX0B13	cus_01KSR173ECD4A2AJF6H3R1H2J8	product_view	product	prod_01KV5D7S5A3GT3TNV6JJ36QA88	\N	2026-08-13 22:53:30.634+02	2026-08-13 22:53:30.634+02	\N
01KZYEDWHW7HDNB6W7Y37SB3J7	cus_01KSR173ECD4A2AJF6H3R1H2J8	product_view	product	prod_01KV5D7S5A3GT3TNV6JJ36QA88	\N	2026-08-13 22:53:41.565+02	2026-08-13 22:53:41.565+02	\N
01KZYEHYE863QAVNA0W1X0603V	cus_01KSR173ECD4A2AJF6H3R1H2J8	product_view	product	prod_01KV5DPWQMJ87E724G2PHS05ZZ	\N	2026-08-13 22:55:54.568+02	2026-08-13 22:55:54.568+02	\N
01KZYEMCZMQ7CQ2PJ004YKE9QX	cus_01KSR173ECD4A2AJF6H3R1H2J8	product_view	product	prod_01KV5D7S5A3GT3TNV6JJ36QA88	\N	2026-08-13 22:57:14.996+02	2026-08-13 22:57:14.996+02	\N
01KZYEQX28FBX2Z2NNJ098QZ5T	cus_01KSR173ECD4A2AJF6H3R1H2J8	checkout_step	cart	cart_01KVAGCKDTWERGJ7WG6JW897EZ	{"step": "payment"}	2026-08-13 22:59:09.769+02	2026-08-13 22:59:09.769+02	\N
01KZYER19GM6YP46RKF4RC6ETD	cus_01KSR173ECD4A2AJF6H3R1H2J8	checkout_step	cart	cart_01KVAGCKDTWERGJ7WG6JW897EZ	{"step": "confirm"}	2026-08-13 22:59:14.096+02	2026-08-13 22:59:14.096+02	\N
01KZYEWZP0203FJAXMN822JD9B	cus_01KSR173ECD4A2AJF6H3R1H2J8	product_view	product	prod_01KVAHVT1115P37Z781SCQWX1W	\N	2026-08-13 23:01:56.289+02	2026-08-13 23:01:56.289+02	\N
01KZYEX964VB5FDGZQJYXXYWRH	cus_01KSR173ECD4A2AJF6H3R1H2J8	product_view	product	prod_01KVANBHYVPHYHTH3VKVZDF1VJ	\N	2026-08-13 23:02:06.021+02	2026-08-13 23:02:06.021+02	\N
01KZYEXH0YY2ZCKJ6CVJKW0M43	cus_01KSR173ECD4A2AJF6H3R1H2J8	product_view	product	prod_01KV5E601185BKG901X7QG2CEW	\N	2026-08-13 23:02:14.047+02	2026-08-13 23:02:14.047+02	\N
01KZYEXR344P6D4KNEDSPKMXX9	cus_01KSR173ECD4A2AJF6H3R1H2J8	product_view	product	prod_01KV5K1Y66BRSD3K4GDMN4M1YS	\N	2026-08-13 23:02:21.285+02	2026-08-13 23:02:21.285+02	\N
01KZYEXY01NE5CAFSZ638S09BG	cus_01KSR173ECD4A2AJF6H3R1H2J8	add_to_cart	product	prod_01KV5K1Y66BRSD3K4GDMN4M1YS	{"via": "buy_now", "quantity": 1, "variant_id": "variant_01KV5K1Y7ZB131EVPGZ9M407MM"}	2026-08-13 23:02:27.33+02	2026-08-13 23:02:27.33+02	\N
01KZYEY2ZF20Y3SCANNFDZ0ESC	cus_01KSR173ECD4A2AJF6H3R1H2J8	checkout_step	cart	cart_01KVAGCKDTWERGJ7WG6JW897EZ	{"step": "payment"}	2026-08-13 23:02:32.431+02	2026-08-13 23:02:32.431+02	\N
01KZYEYNCXWC4MR98C3PM1KBBD	cus_01KSR173ECD4A2AJF6H3R1H2J8	checkout_step	cart	cart_01KVAGCKDTWERGJ7WG6JW897EZ	{"step": "confirm"}	2026-08-13 23:02:51.293+02	2026-08-13 23:02:51.293+02	\N
01M015FGRGE1DEKDDZ7TSBQQE7	cus_01KSR173ECD4A2AJF6H3R1H2J8	product_view	product	prod_01KVAHVT1115P37Z781SCQWX1W	\N	2026-08-15 00:15:01.136+02	2026-08-15 00:15:01.136+02	\N
01M02ENA7N5ESWX8HM8FREAZDG	cus_01KVDNF9NVQVFFF9WFB56HN13V	product_view	product	prod_01KV5K1Y66BRSD3K4GDMN4M1YS	\N	2026-08-15 12:14:42.677+02	2026-08-15 12:14:42.677+02	\N
01M03BG2TRH3NZQ5XC4SB9F247	cus_01KSR173ECD4A2AJF6H3R1H2J8	product_view	product	prod_01KSCR9EA8QJ19M3XNSJCQTBKP	\N	2026-08-15 20:38:39.961+02	2026-08-15 20:38:39.961+02	\N
01M03BP70G9K70PB0HBKYY4EEW	cus_01KSR173ECD4A2AJF6H3R1H2J8	product_view	product	prod_01KT156V00QYP2NS7HYG4BWMYG	\N	2026-08-15 20:42:00.849+02	2026-08-15 20:42:00.849+02	\N
01M03BR8FC74PD4K8XPGSNWMAK	cus_01KSR173ECD4A2AJF6H3R1H2J8	product_view	product	prod_01KSCR9EA8QJ19M3XNSJCQTBKP	\N	2026-08-15 20:43:07.884+02	2026-08-15 20:43:07.884+02	\N
01M03BRNB6F2F364VE94MZSZYM	cus_01KSR173ECD4A2AJF6H3R1H2J8	search	search_query	\N	{"query": "Laser cutter"}	2026-08-15 20:43:21.062+02	2026-08-15 20:43:21.062+02	\N
01M03BV8S23TQTNQF1M9XEFSJB	cus_01KSR173ECD4A2AJF6H3R1H2J8	product_view	product	prod_01KSH2A8YPQ2M4AN368YBJ9X3C	\N	2026-08-15 20:44:46.498+02	2026-08-15 20:44:46.498+02	\N
01M03C68TA0ZNPP04C546VT8VT	cus_01KSR173ECD4A2AJF6H3R1H2J8	product_view	product	prod_01KVAHVT1115P37Z781SCQWX1W	\N	2026-08-15 20:50:46.986+02	2026-08-15 20:50:46.986+02	\N
\.


--
-- Data for Name: user_preference; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_preference (id, user_id, key, value, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: user_rbac_role; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_rbac_role (user_id, rbac_role_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: vendor; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.vendor (id, handle, name, logo, created_at, updated_at, deleted_at, cover_image, description, phone, email, website, country, city, address, founded_year, business_type, main_products, employee_count, social_links, is_verified, response_rate, response_time, balance) FROM stdin;
01KSCS6FH5H9J6QY6ZPJ0110W5	bbbbb	Myself 	\N	2026-05-24 12:41:22.47+02	2026-05-24 12:41:22.47+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	0
01KSCSTSP7N25SPSF2H5AK45FY	uuuu	Myself 	\N	2026-05-24 12:52:28.231+02	2026-08-15 23:00:00.088+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	0	\N	0
01KV5CHYWYZVSNYGB0RXEYG5CK	tangastore1	Tanga store 	https://s3.eastmarket.africa/eastmarket/image-01KV5CMRQXX70PRQ2N58ZQASMZ.jpg	2026-06-15 12:17:09.79+02	2026-08-15 23:00:00.093+02	\N	\N	Nous vendons des souliers de qualité supérieure 	67881752	princelulinda@gmail.com	\N	Burundi 	Bujumbura ville 	Bujumbura, Burundi 	\N	\N	\N	\N	{"instagram": "sania.bi"}	f	0	\N	0
01KV54RE49JJGZ7AKCXD50T1KQ	\N	Test Vendor	\N	2026-06-15 10:00:53.385+02	2026-06-15 10:00:53.385+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	0
01KV57JBZBPRJ93AM3PSKFTMMH	princelulinda61gmailcom	princelulinda61@gmail.com	\N	2026-06-15 10:50:00.3+02	2026-06-15 10:50:00.3+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	0
01KV5BKD1AJJMVMXVX11GRATWB	merci	Merci 	\N	2026-06-15 12:00:28.458+02	2026-06-15 12:00:28.458+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	0
01KV5BPJD0BHQNMDBVA7EPR3R1	tangastore	Tanga store	https://s3.eastmarket.africa/eastmarket/image-01KV5BQQRXT6N3SJCXGP9393VV.jpg	2026-06-15 12:02:12.256+02	2026-06-15 12:03:00.345+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	0
01KV660ATKQP58J260MPW7RQ8R	kinshop	Kinshop	https://s3.eastmarket.africa/eastmarket/image-01KV6627G5B2082DZKNG25NA6M.jpg	2026-06-15 19:41:55.155+02	2026-06-15 20:46:06.729+02	\N	https://s3.eastmarket.africa/eastmarket/image-01KV69MQ3SR3QM7H74X8JV7D3Y.jpg	\N	\N	\N	\N	\N	\N	\N	\N	retailer	\N	\N	{}	f	\N	\N	0
01KV69YB45Q6QNDRG5VPA4X643	bujastore	Buja store	https://s3.eastmarket.africa/eastmarket/image-01KV69ZWPCZVFW94KAN0RRCEH9.jpg	2026-06-15 20:50:44.229+02	2026-06-15 20:52:13.855+02	\N	https://s3.eastmarket.africa/eastmarket/image-01KV69ZB5ANAM781K50ZBC1ME1.jpg	\N	\N	\N	\N	\N	\N	\N	\N	wholesaler	\N	\N	{}	f	\N	\N	0
01KWSMG9MENSKS30A5SCWX8JW2	kinamashop	Kinama shop	https://s3.eastmarket.africa/eastmarket/image-01KWSMHV9A5QAE4ZX98V1KX76Z.jpg	2026-07-05 19:16:34.319+02	2026-07-05 19:18:02.355+02	\N	https://s3.eastmarket.africa/eastmarket/image-01KWSMH6CVGXKRFCYB894939BN.jpg	\N	\N	\N	\N	bi	\N	Kinama,  12	\N	retailer	\N	\N	{}	f	\N	\N	0
01KZSNE0N2NMDBYY9W8KGY0GJW	flash-test-vendor	Flash Test Vendor	\N	2026-08-12 02:19:53.634+02	2026-08-12 02:19:53.634+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	0
01KSDE9JVTNAXE0NF67DNVEWBS	yyyyy	My boutique 	http://localhost:9000/static/1779642732390-image.jpg	2026-05-24 18:50:04.282+02	2026-08-15 23:00:00.082+02	\N	\N	Hello	\N	\N	http///sannia.bi	\N	\N	\N	\N	trader	\N	\N	{"instagram": "https://Instagram.com"}	f	100	Répond en ~15 min	0
\.


--
-- Data for Name: vendor_admin; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.vendor_admin (id, first_name, last_name, email, vendor_id, created_at, updated_at, deleted_at) FROM stdin;
01KSCS6FHM3T088JTDVNHWEAP0	Prince 	Lulinda 	princelulinda12@gmail.com	01KSCS6FH5H9J6QY6ZPJ0110W5	2026-05-24 12:41:22.484+02	2026-05-24 12:41:22.484+02	\N
01KSCSTSPDSEAN744XV198F4RD	Prince 	Crespo 	princelulinda1@gmail.com	01KSCSTSP7N25SPSF2H5AK45FY	2026-05-24 12:52:28.237+02	2026-05-24 12:52:28.237+02	\N
01KSDE9JW0MFK1W1NWQ29QV25V	Prince 	Crespo	princelulinda122@gmail.com	01KSDE9JVTNAXE0NF67DNVEWBS	2026-05-24 18:50:04.288+02	2026-05-24 18:50:04.288+02	\N
01KV54RE4N8QPSN5CHZ9SZYNWC	Test	Vendor	testvendor@example.com	01KV54RE49JJGZ7AKCXD50T1KQ	2026-06-15 10:00:53.398+02	2026-06-15 10:00:53.398+02	\N
01KV57JBZJBSBM5WA0NG4M45HR	Prince 	Crespo	princelulinda61@gmail.com	01KV57JBZBPRJ93AM3PSKFTMMH	2026-06-15 10:50:00.306+02	2026-06-15 10:50:00.306+02	\N
01KV5BKD1EKP3MQ5XSTZXDK22X	App 	Pp	princelulinda0001@gmail.com	01KV5BKD1AJJMVMXVX11GRATWB	2026-06-15 12:00:28.462+02	2026-06-15 12:00:28.462+02	\N
01KV5BPJD5F7AVY4D00DCTWX6G	Prince 	Lulinda 	prince@gmail.com	01KV5BPJD0BHQNMDBVA7EPR3R1	2026-06-15 12:02:12.261+02	2026-06-15 12:02:12.261+02	\N
01KV5CHYXFFSYJHQ816P112AMS	Prince 	Lulinda 	princelulinda1002@gmail.com	01KV5CHYWYZVSNYGB0RXEYG5CK	2026-06-15 12:17:09.807+02	2026-06-15 12:17:09.807+02	\N
01KV660ATYEE23FKSY15PCJAAF	Crespo 	Prince 	princelulinda2@gmail.com	01KV660ATKQP58J260MPW7RQ8R	2026-06-15 19:41:55.167+02	2026-06-15 19:41:55.167+02	\N
01KV69YB4B12G19BWNKS8TEGA2	Jule	Akili	princelulinda333@gmail.com	01KV69YB45Q6QNDRG5VPA4X643	2026-06-15 20:50:44.236+02	2026-06-15 20:50:44.236+02	\N
01KWSMG9MVNFPCA37HG7TJ35KN	Prince	Lulinda 	princelulinda87@gmail.com	01KWSMG9MENSKS30A5SCWX8JW2	2026-07-05 19:16:34.332+02	2026-07-05 19:16:34.332+02	\N
01KZSNE0NACP4N12MCZ8A4CFC1	Flash	Tester	flashsaletest2@example.com	01KZSNE0N2NMDBYY9W8KGY0GJW	2026-08-12 02:19:53.642+02	2026-08-12 02:19:53.642+02	\N
\.


--
-- Data for Name: vendor_follow; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.vendor_follow (id, customer_id, vendor_id, created_at, updated_at, deleted_at) FROM stdin;
01KZV2D24J1X8P74H3SN95RTXT	cus_01KSR173ECD4A2AJF6H3R1H2J8	01KV5CHYWYZVSNYGB0RXEYG5CK	2026-08-12 15:25:48.306+02	2026-08-12 15:25:48.306+02	\N
01KZV2D24NVSS3JM94RMT32TX9	cus_01KSR173ECD4A2AJF6H3R1H2J8	01KV5CHYWYZVSNYGB0RXEYG5CK	2026-08-12 15:25:48.309+02	2026-08-12 15:25:48.309+02	\N
01KZV3P6NN1W9Z5FK75S11WQY3	cus_01KZTFASX63451FWPYQZST4A8M	01KSDE9JVTNAXE0NF67DNVEWBS	2026-08-12 15:48:16.438+02	2026-08-12 15:48:16.438+02	\N
01KZV4AMF1M5BP5WZACCSHW3YM	cus_01KZV2PTYGTZ4E2VCQ7R28NYVF	01KSCSTSP7N25SPSF2H5AK45FY	2026-08-12 15:59:25.921+02	2026-08-12 15:59:25.921+02	\N
\.


--
-- Data for Name: vendor_payout; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.vendor_payout (id, amount, status, payment_method, payment_details, rejection_reason, vendor_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: video_comment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.video_comment (id, video_id, customer_id, content, created_at, updated_at, deleted_at, vendor_id, parent_id) FROM stdin;
01KSS5SWJBWC4WKWXK1HFC69SE	01KSRBXKRZRKXFAZK6VWV2WNBW	cus_01KSR173ECD4A2AJF6H3R1H2J8	Hello	2026-05-29 08:12:34.507+02	2026-05-29 08:12:34.507+02	\N	\N	\N
01KSS5T80VTNK54P0KQW8XK2P5	01KSRBXKRZRKXFAZK6VWV2WNBW	cus_01KSR173ECD4A2AJF6H3R1H2J8	No	2026-05-29 08:12:46.235+02	2026-05-29 08:12:46.235+02	\N	\N	01KSS5SWJBWC4WKWXK1HFC69SE
01KTFEDD0K51H11XGPH2FEQKC4	01KSRBXKRZRKXFAZK6VWV2WNBW	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour	2026-06-06 23:46:20.051+02	2026-06-06 23:46:20.051+02	\N	\N	\N
\.


--
-- Data for Name: video_like; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.video_like (id, video_id, customer_id, created_at, updated_at, deleted_at) FROM stdin;
01KSS37T1K3J0JQ9WXN9FYVXGE	01KSRBWX4WCXHWPJ5AM9C54AS2	cus_01KSR173ECD4A2AJF6H3R1H2J8	2026-05-29 07:27:44.947+02	2026-05-29 07:27:44.947+02	\N
01KSWSGDFEK3M02APSWPVJFNZ4	01KSRBWX4WCXHWPJ5AM9C54AS2	cus_01KSWS7V39C4SDB1YTY9K83SMS	2026-05-30 17:54:38.959+02	2026-05-30 17:54:38.959+02	\N
01KTFEH2ST5D3BF7YAKAD910JV	01KSRBXKRZRKXFAZK6VWV2WNBW	cus_01KSR173ECD4A2AJF6H3R1H2J8	2026-06-06 23:48:20.666+02	2026-06-06 23:48:20.666+02	\N
01KZSMHH4X1E6WJMNN92FG6ACF	01KV5D881Y13B5R93K3KSVS0RC	cus_01KSR173ECD4A2AJF6H3R1H2J8	2026-08-12 02:04:20.253+02	2026-08-12 02:04:20.253+02	\N
01KZV4606VXZ9G2FYF7PZAXS1B	01KSRB09F12K4PY852ZDN2R3MQ	cus_01KZV2PTYGTZ4E2VCQ7R28NYVF	2026-08-12 15:56:54.107+02	2026-08-12 15:56:54.107+02	\N
\.


--
-- Data for Name: video_save; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.video_save (id, video_id, customer_id, created_at, updated_at, deleted_at) FROM stdin;
01KSRC6GWAAT3Z0NRQB9V9EEBQ	01KSRBWX4WCXHWPJ5AM9C54AS2	cus_01KSR173ECD4A2AJF6H3R1H2J8	2026-05-29 00:45:05.547+02	2026-05-29 00:45:05.547+02	\N
01KSSQHWGE1Q4NHKCHGQ52YQ07	01KSRB09F12K4PY852ZDN2R3MQ	cus_01KSR173ECD4A2AJF6H3R1H2J8	2026-05-29 13:22:46.67+02	2026-05-29 13:22:46.67+02	\N
\.


--
-- Data for Name: view_configuration; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.view_configuration (id, entity, name, user_id, is_system_default, configuration, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: wheel_prize; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.wheel_prize (id, label, prize_type, points_value, coupon_discount_value, coupon_validity_days, weight, color, icon, is_active, sort_order, created_at, updated_at, deleted_at) FROM stdin;
wprz_a664f4db39595699dce91492	20 pts	points	20	\N	\N	30	#FFD9C2	star	t	0	2026-08-12 01:58:52.834508+02	2026-08-12 01:58:52.834508+02	\N
wprz_73f30ffadc83489f01b3ebdb	50 pts	points	50	\N	\N	20	#FFB088	star	t	1	2026-08-12 01:58:52.845539+02	2026-08-12 01:58:52.845539+02	\N
wprz_267313fbe8ea6295ef90622d	Try again	no_win	\N	\N	\N	20	#F0F0F0	refresh	t	2	2026-08-12 01:58:52.846402+02	2026-08-12 01:58:52.846402+02	\N
wprz_d658ff6309d2b2906181ce99	100 pts	points	100	\N	\N	12	#FF9E66	star	t	3	2026-08-12 01:58:52.847201+02	2026-08-12 01:58:52.847201+02	\N
wprz_ac48526213bb420e591d0b03	5% off	coupon_percentage	\N	5	5	10	#FF7A3D	pricetag	t	4	2026-08-12 01:58:52.848051+02	2026-08-12 01:58:52.848051+02	\N
wprz_409986c50d29ec4ff7d0c3d6	Free shipping	free_shipping	\N	\N	7	5	#FF6420	cube	t	5	2026-08-12 01:58:52.848838+02	2026-08-12 01:58:52.848838+02	\N
wprz_4537e45685076253a9444917	10% off	coupon_percentage	\N	10	7	3	#FF5000	pricetag	t	6	2026-08-12 01:59:33.647579+02	2026-08-12 01:59:33.647579+02	\N
wprz_44b19e864f8085ac0d88b2f9	Jackpot 300 pts	points	300	\N	\N	1	#E64400	trophy	t	7	2026-08-12 01:59:33.659126+02	2026-08-12 01:59:33.659126+02	\N
\.


--
-- Data for Name: wheel_spin; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.wheel_spin (id, prize_id, spin_date, points_earned, coupon_id, loyalty_id, created_at, updated_at, deleted_at) FROM stdin;
01KZSMBJ4F5J3JN4EX3319MSDP	wprz_73f30ffadc83489f01b3ebdb	2026-08-12	50	\N	01KZSMB2RF3BMZMHR0S0R0SJ6K	2026-08-12 02:01:04.656+02	2026-08-12 02:01:04.656+02	\N
01KZSMBY6GZ8N19F8HCM6WA8C4	wprz_267313fbe8ea6295ef90622d	2026-08-12	0	\N	01KZSMA4A7553XA5H9TZKBH0E8	2026-08-12 02:01:17.008+02	2026-08-12 02:01:17.008+02	\N
01KZSMBZDE8TKF8VK72R61238G	wprz_a664f4db39595699dce91492	2026-08-12	20	\N	01KZSMBZD4H1C9STH238FXZRAB	2026-08-12 02:01:18.254+02	2026-08-12 02:01:18.254+02	\N
01KZSMBZNKQ5A39WHA6F5DA3CM	wprz_73f30ffadc83489f01b3ebdb	2026-08-12	50	\N	01KZSMBZNBJFHRKXF7V72Q9NMA	2026-08-12 02:01:18.515+02	2026-08-12 02:01:18.515+02	\N
01KZSMBZXG7FS7KMRYD6P4P9EN	wprz_a664f4db39595699dce91492	2026-08-12	20	\N	01KZSMBZXAVZ40471N9B5ADJ5Q	2026-08-12 02:01:18.768+02	2026-08-12 02:01:18.768+02	\N
01KZSMC05BQQ53GH58D9WE926V	wprz_267313fbe8ea6295ef90622d	2026-08-12	0	\N	01KZSMC053G1K8N298J950H9W8	2026-08-12 02:01:19.02+02	2026-08-12 02:01:19.02+02	\N
01KZSMC0D1WHRMGF5Z4M23BQM9	wprz_73f30ffadc83489f01b3ebdb	2026-08-12	50	\N	01KZSMC0CWH0MBAEPZ6WBW7WYS	2026-08-12 02:01:19.266+02	2026-08-12 02:01:19.266+02	\N
01KZSMC0N8RDC96ETHYHB1VRNB	wprz_a664f4db39595699dce91492	2026-08-12	20	\N	01KZSMC0MZFK1N43XZ12952K6R	2026-08-12 02:01:19.528+02	2026-08-12 02:01:19.528+02	\N
01KZSMC0XKA4K5A3AXSAX0FFN9	wprz_73f30ffadc83489f01b3ebdb	2026-08-12	50	\N	01KZSMC0XD0KC9R865TEBQN2NS	2026-08-12 02:01:19.795+02	2026-08-12 02:01:19.795+02	\N
01KZSMC159ZFVGJDSWZCZFNT1N	wprz_d658ff6309d2b2906181ce99	2026-08-12	100	\N	01KZSMC151SK5MMQE0NPK6WQQP	2026-08-12 02:01:20.041+02	2026-08-12 02:01:20.041+02	\N
01KZSMC1CYBMPTF07NM1SRK8R9	wprz_267313fbe8ea6295ef90622d	2026-08-12	0	\N	01KZSMC1CQ31MKXNZS57BS2WVW	2026-08-12 02:01:20.286+02	2026-08-12 02:01:20.286+02	\N
01KZSMC1MDV0RJZBE6EQ5XKK2N	wprz_ac48526213bb420e591d0b03	2026-08-12	0	01KZSMC1N6Z0HXKWTY4TY0BRW8	01KZSMC1M7PN2ST3VDMFTRZPNP	2026-08-12 02:01:20.526+02	2026-08-12 02:01:20.554+02	\N
01KZSMC1YEVPPXFKAR3V07078B	wprz_267313fbe8ea6295ef90622d	2026-08-12	0	\N	01KZSMC1Y5WX9ECK76WMCV1VA7	2026-08-12 02:01:20.847+02	2026-08-12 02:01:20.847+02	\N
01KZSMC26D3CZRJY0308M6YCSZ	wprz_d658ff6309d2b2906181ce99	2026-08-12	100	\N	01KZSMC263XPVH5ENACB0GAXHG	2026-08-12 02:01:21.101+02	2026-08-12 02:01:21.101+02	\N
01KZSMEXTM5GG4NYQE8K3N0RDJ	wprz_a664f4db39595699dce91492	2026-08-12	20	\N	01KZSMEXT5JZ5CZW5KC01CKGAD	2026-08-12 02:02:54.932+02	2026-08-12 02:02:54.932+02	\N
01KZSMEY4K94AWQ27A51SYGVBB	wprz_4537e45685076253a9444917	2026-08-12	0	01KZSMEY5NZBK8RPPP0B5EH6XZ	01KZSMEY48FZPAN6WKC834535M	2026-08-12 02:02:55.251+02	2026-08-12 02:02:55.292+02	\N
01KZTF1CDT8BM2P562XP5F6023	wprz_d658ff6309d2b2906181ce99	2026-08-12	100	\N	01KZTEX2KPQ3HPRRSZB4J21987	2026-08-12 09:47:22.682+02	2026-08-12 09:47:22.682+02	\N
01KZV2S9QKDEP650Z1F89QXMPD	wprz_a664f4db39595699dce91492	2026-08-12	20	\N	01KZV2R16R60TMY8APYCMJFQS3	2026-08-12 15:32:29.299+02	2026-08-12 15:32:29.299+02	\N
01KZYEPW87HHYQHCXZGTF4CB5M	wprz_409986c50d29ec4ff7d0c3d6	2026-08-13	0	01KZYEPWAC5PZFXTEJ5HJSDJXS	01KZSMA4A7553XA5H9TZKBH0E8	2026-08-13 22:58:36.168+02	2026-08-13 22:58:36.246+02	\N
01M01CHCFWVYDBFD5QAC697EPQ	wprz_d658ff6309d2b2906181ce99	2026-08-15	100	\N	01M0192MZDR43Q5FNHXCN6RBJT	2026-08-15 02:18:22.332+02	2026-08-15 02:18:22.332+02	\N
01M02EPYRA1WRXZ4PB2N2W7D92	wprz_73f30ffadc83489f01b3ebdb	2026-08-15	50	\N	01M02EP57WV5EYJ9NA2ZXP9V21	2026-08-15 12:15:36.458+02	2026-08-15 12:15:36.459+02	\N
01M03DTR5D4V87T77JW8TC5YYY	wprz_267313fbe8ea6295ef90622d	2026-08-15	0	\N	01KZSMA4A7553XA5H9TZKBH0E8	2026-08-15 21:19:26.637+02	2026-08-15 21:19:26.637+02	\N
\.


--
-- Data for Name: workflow_execution; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.workflow_execution (id, workflow_id, transaction_id, execution, context, state, created_at, updated_at, deleted_at, retention_time, run_id) FROM stdin;
\.


--
-- Name: link_module_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.link_module_migrations_id_seq', 664, true);


--
-- Name: mikro_orm_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.mikro_orm_migrations_id_seq', 193, true);


--
-- Name: order_change_action_ordering_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_change_action_ordering_seq', 6, true);


--
-- Name: order_claim_display_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_claim_display_id_seq', 1, false);


--
-- Name: order_display_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_display_id_seq', 21, true);


--
-- Name: order_exchange_display_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_exchange_display_id_seq', 1, false);


--
-- Name: return_display_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.return_display_id_seq', 1, false);


--
-- Name: script_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.script_migrations_id_seq', 2, true);


--
-- Name: account_holder account_holder_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_holder
    ADD CONSTRAINT account_holder_pkey PRIMARY KEY (id);


--
-- Name: analytics_event analytics_event_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analytics_event
    ADD CONSTRAINT analytics_event_pkey PRIMARY KEY (id);


--
-- Name: api_key api_key_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_key
    ADD CONSTRAINT api_key_pkey PRIMARY KEY (id);


--
-- Name: app_notification app_notification_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_notification
    ADD CONSTRAINT app_notification_pkey PRIMARY KEY (id);


--
-- Name: application_method_buy_rules application_method_buy_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_method_buy_rules
    ADD CONSTRAINT application_method_buy_rules_pkey PRIMARY KEY (application_method_id, promotion_rule_id);


--
-- Name: application_method_target_rules application_method_target_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_method_target_rules
    ADD CONSTRAINT application_method_target_rules_pkey PRIMARY KEY (application_method_id, promotion_rule_id);


--
-- Name: auth_identity auth_identity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_identity
    ADD CONSTRAINT auth_identity_pkey PRIMARY KEY (id);


--
-- Name: capture capture_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.capture
    ADD CONSTRAINT capture_pkey PRIMARY KEY (id);


--
-- Name: cart_address cart_address_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_address
    ADD CONSTRAINT cart_address_pkey PRIMARY KEY (id);


--
-- Name: cart_line_item_adjustment cart_line_item_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_line_item_adjustment
    ADD CONSTRAINT cart_line_item_adjustment_pkey PRIMARY KEY (id);


--
-- Name: cart_line_item cart_line_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_line_item
    ADD CONSTRAINT cart_line_item_pkey PRIMARY KEY (id);


--
-- Name: cart_line_item_tax_line cart_line_item_tax_line_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_line_item_tax_line
    ADD CONSTRAINT cart_line_item_tax_line_pkey PRIMARY KEY (id);


--
-- Name: cart_payment_collection cart_payment_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_payment_collection
    ADD CONSTRAINT cart_payment_collection_pkey PRIMARY KEY (cart_id, payment_collection_id);


--
-- Name: cart cart_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_pkey PRIMARY KEY (id);


--
-- Name: cart_promotion cart_promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_promotion
    ADD CONSTRAINT cart_promotion_pkey PRIMARY KEY (cart_id, promotion_id);


--
-- Name: cart_shipping_method_adjustment cart_shipping_method_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_shipping_method_adjustment
    ADD CONSTRAINT cart_shipping_method_adjustment_pkey PRIMARY KEY (id);


--
-- Name: cart_shipping_method cart_shipping_method_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_shipping_method
    ADD CONSTRAINT cart_shipping_method_pkey PRIMARY KEY (id);


--
-- Name: cart_shipping_method_tax_line cart_shipping_method_tax_line_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_shipping_method_tax_line
    ADD CONSTRAINT cart_shipping_method_tax_line_pkey PRIMARY KEY (id);


--
-- Name: conversation conversation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversation
    ADD CONSTRAINT conversation_pkey PRIMARY KEY (id);


--
-- Name: credit_line credit_line_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_line
    ADD CONSTRAINT credit_line_pkey PRIMARY KEY (id);


--
-- Name: currency currency_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency
    ADD CONSTRAINT currency_pkey PRIMARY KEY (code);


--
-- Name: customer_account_holder customer_account_holder_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_account_holder
    ADD CONSTRAINT customer_account_holder_pkey PRIMARY KEY (customer_id, account_holder_id);


--
-- Name: customer_address customer_address_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_address
    ADD CONSTRAINT customer_address_pkey PRIMARY KEY (id);


--
-- Name: customer_group_customer customer_group_customer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_group_customer
    ADD CONSTRAINT customer_group_customer_pkey PRIMARY KEY (id);


--
-- Name: customer_group customer_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_group
    ADD CONSTRAINT customer_group_pkey PRIMARY KEY (id);


--
-- Name: customer_loyalty customer_loyalty_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_loyalty
    ADD CONSTRAINT customer_loyalty_pkey PRIMARY KEY (id);


--
-- Name: customer_payment_method customer_payment_method_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_payment_method
    ADD CONSTRAINT customer_payment_method_pkey PRIMARY KEY (id);


--
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (id);


--
-- Name: daily_check_in daily_check_in_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_check_in
    ADD CONSTRAINT daily_check_in_pkey PRIMARY KEY (id);


--
-- Name: delivery_company delivery_company_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_company
    ADD CONSTRAINT delivery_company_pkey PRIMARY KEY (id);


--
-- Name: delivery_delivery_company_fulfillment_shipping_option delivery_delivery_company_fulfillment_shipping_option_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_delivery_company_fulfillment_shipping_option
    ADD CONSTRAINT delivery_delivery_company_fulfillment_shipping_option_pkey PRIMARY KEY (delivery_company_id, shipping_option_id);


--
-- Name: delivery_driver delivery_driver_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_driver
    ADD CONSTRAINT delivery_driver_pkey PRIMARY KEY (id);


--
-- Name: flash_sale flash_sale_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flash_sale
    ADD CONSTRAINT flash_sale_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_address fulfillment_address_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillment_address
    ADD CONSTRAINT fulfillment_address_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_item fulfillment_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillment_item
    ADD CONSTRAINT fulfillment_item_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_label fulfillment_label_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillment_label
    ADD CONSTRAINT fulfillment_label_pkey PRIMARY KEY (id);


--
-- Name: fulfillment fulfillment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT fulfillment_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_provider fulfillment_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillment_provider
    ADD CONSTRAINT fulfillment_provider_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_set fulfillment_set_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillment_set
    ADD CONSTRAINT fulfillment_set_pkey PRIMARY KEY (id);


--
-- Name: geo_zone geo_zone_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.geo_zone
    ADD CONSTRAINT geo_zone_pkey PRIMARY KEY (id);


--
-- Name: image image_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_pkey PRIMARY KEY (id);


--
-- Name: inventory_item inventory_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_item
    ADD CONSTRAINT inventory_item_pkey PRIMARY KEY (id);


--
-- Name: inventory_level inventory_level_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_level
    ADD CONSTRAINT inventory_level_pkey PRIMARY KEY (id);


--
-- Name: invite invite_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invite
    ADD CONSTRAINT invite_pkey PRIMARY KEY (id);


--
-- Name: link_module_migrations link_module_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link_module_migrations
    ADD CONSTRAINT link_module_migrations_pkey PRIMARY KEY (id);


--
-- Name: link_module_migrations link_module_migrations_table_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link_module_migrations
    ADD CONSTRAINT link_module_migrations_table_name_key UNIQUE (table_name);


--
-- Name: locale locale_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locale
    ADD CONSTRAINT locale_pkey PRIMARY KEY (id);


--
-- Name: location_fulfillment_provider location_fulfillment_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_fulfillment_provider
    ADD CONSTRAINT location_fulfillment_provider_pkey PRIMARY KEY (stock_location_id, fulfillment_provider_id);


--
-- Name: location_fulfillment_set location_fulfillment_set_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_fulfillment_set
    ADD CONSTRAINT location_fulfillment_set_pkey PRIMARY KEY (stock_location_id, fulfillment_set_id);


--
-- Name: loyalty_coupon loyalty_coupon_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loyalty_coupon
    ADD CONSTRAINT loyalty_coupon_pkey PRIMARY KEY (id);


--
-- Name: loyalty_transaction loyalty_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.loyalty_transaction
    ADD CONSTRAINT loyalty_transaction_pkey PRIMARY KEY (id);


--
-- Name: marketplace_vendor_order_order marketplace_vendor_order_order_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketplace_vendor_order_order
    ADD CONSTRAINT marketplace_vendor_order_order_pkey PRIMARY KEY (vendor_id, order_id);


--
-- Name: marketplace_vendor_product_product marketplace_vendor_product_product_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketplace_vendor_product_product
    ADD CONSTRAINT marketplace_vendor_product_product_pkey PRIMARY KEY (vendor_id, product_id);


--
-- Name: marketplace_vendor_promotion_promotion marketplace_vendor_promotion_promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketplace_vendor_promotion_promotion
    ADD CONSTRAINT marketplace_vendor_promotion_promotion_pkey PRIMARY KEY (vendor_id, promotion_id);


--
-- Name: marketplace_vendor_stock_location_stock_location marketplace_vendor_stock_location_stock_location_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketplace_vendor_stock_location_stock_location
    ADD CONSTRAINT marketplace_vendor_stock_location_stock_location_pkey PRIMARY KEY (vendor_id, stock_location_id);


--
-- Name: message message_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message
    ADD CONSTRAINT message_pkey PRIMARY KEY (id);


--
-- Name: mikro_orm_migrations mikro_orm_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mikro_orm_migrations
    ADD CONSTRAINT mikro_orm_migrations_pkey PRIMARY KEY (id);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- Name: notification_preference notification_preference_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_preference
    ADD CONSTRAINT notification_preference_pkey PRIMARY KEY (id);


--
-- Name: notification_provider notification_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_provider
    ADD CONSTRAINT notification_provider_pkey PRIMARY KEY (id);


--
-- Name: order_address order_address_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_address
    ADD CONSTRAINT order_address_pkey PRIMARY KEY (id);


--
-- Name: order_cart order_cart_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_cart
    ADD CONSTRAINT order_cart_pkey PRIMARY KEY (order_id, cart_id);


--
-- Name: order_change_action order_change_action_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_change_action
    ADD CONSTRAINT order_change_action_pkey PRIMARY KEY (id);


--
-- Name: order_change order_change_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_change
    ADD CONSTRAINT order_change_pkey PRIMARY KEY (id);


--
-- Name: order_claim_item_image order_claim_item_image_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_claim_item_image
    ADD CONSTRAINT order_claim_item_image_pkey PRIMARY KEY (id);


--
-- Name: order_claim_item order_claim_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_claim_item
    ADD CONSTRAINT order_claim_item_pkey PRIMARY KEY (id);


--
-- Name: order_claim order_claim_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_claim
    ADD CONSTRAINT order_claim_pkey PRIMARY KEY (id);


--
-- Name: order_credit_line order_credit_line_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_credit_line
    ADD CONSTRAINT order_credit_line_pkey PRIMARY KEY (id);


--
-- Name: order_exchange_item order_exchange_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_exchange_item
    ADD CONSTRAINT order_exchange_item_pkey PRIMARY KEY (id);


--
-- Name: order_exchange order_exchange_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_exchange
    ADD CONSTRAINT order_exchange_pkey PRIMARY KEY (id);


--
-- Name: order_fulfillment order_fulfillment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_fulfillment
    ADD CONSTRAINT order_fulfillment_pkey PRIMARY KEY (order_id, fulfillment_id);


--
-- Name: order_item order_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_pkey PRIMARY KEY (id);


--
-- Name: order_line_item_adjustment order_line_item_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_line_item_adjustment
    ADD CONSTRAINT order_line_item_adjustment_pkey PRIMARY KEY (id);


--
-- Name: order_line_item order_line_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_line_item
    ADD CONSTRAINT order_line_item_pkey PRIMARY KEY (id);


--
-- Name: order_line_item_tax_line order_line_item_tax_line_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_line_item_tax_line
    ADD CONSTRAINT order_line_item_tax_line_pkey PRIMARY KEY (id);


--
-- Name: order_payment_collection order_payment_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_payment_collection
    ADD CONSTRAINT order_payment_collection_pkey PRIMARY KEY (order_id, payment_collection_id);


--
-- Name: order order_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_pkey PRIMARY KEY (id);


--
-- Name: order_promotion order_promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_promotion
    ADD CONSTRAINT order_promotion_pkey PRIMARY KEY (order_id, promotion_id);


--
-- Name: order_shipping_method_adjustment order_shipping_method_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_shipping_method_adjustment
    ADD CONSTRAINT order_shipping_method_adjustment_pkey PRIMARY KEY (id);


--
-- Name: order_shipping_method order_shipping_method_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_shipping_method
    ADD CONSTRAINT order_shipping_method_pkey PRIMARY KEY (id);


--
-- Name: order_shipping_method_tax_line order_shipping_method_tax_line_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_shipping_method_tax_line
    ADD CONSTRAINT order_shipping_method_tax_line_pkey PRIMARY KEY (id);


--
-- Name: order_shipping order_shipping_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_shipping
    ADD CONSTRAINT order_shipping_pkey PRIMARY KEY (id);


--
-- Name: order_summary order_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_summary
    ADD CONSTRAINT order_summary_pkey PRIMARY KEY (id);


--
-- Name: order_transaction order_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_transaction
    ADD CONSTRAINT order_transaction_pkey PRIMARY KEY (id);


--
-- Name: payment_collection_payment_providers payment_collection_payment_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_collection_payment_providers
    ADD CONSTRAINT payment_collection_payment_providers_pkey PRIMARY KEY (payment_collection_id, payment_provider_id);


--
-- Name: payment_collection payment_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_collection
    ADD CONSTRAINT payment_collection_pkey PRIMARY KEY (id);


--
-- Name: payment payment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (id);


--
-- Name: payment_provider payment_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_provider
    ADD CONSTRAINT payment_provider_pkey PRIMARY KEY (id);


--
-- Name: payment_session payment_session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_session
    ADD CONSTRAINT payment_session_pkey PRIMARY KEY (id);


--
-- Name: price_list price_list_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.price_list
    ADD CONSTRAINT price_list_pkey PRIMARY KEY (id);


--
-- Name: price_list_rule price_list_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.price_list_rule
    ADD CONSTRAINT price_list_rule_pkey PRIMARY KEY (id);


--
-- Name: price price_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT price_pkey PRIMARY KEY (id);


--
-- Name: price_preference price_preference_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.price_preference
    ADD CONSTRAINT price_preference_pkey PRIMARY KEY (id);


--
-- Name: price_rule price_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.price_rule
    ADD CONSTRAINT price_rule_pkey PRIMARY KEY (id);


--
-- Name: price_set price_set_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.price_set
    ADD CONSTRAINT price_set_pkey PRIMARY KEY (id);


--
-- Name: product_category product_category_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_category
    ADD CONSTRAINT product_category_pkey PRIMARY KEY (id);


--
-- Name: product_category_product product_category_product_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_category_product
    ADD CONSTRAINT product_category_product_pkey PRIMARY KEY (product_id, product_category_id);


--
-- Name: product_collection product_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_collection
    ADD CONSTRAINT product_collection_pkey PRIMARY KEY (id);


--
-- Name: product_option product_option_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_option
    ADD CONSTRAINT product_option_pkey PRIMARY KEY (id);


--
-- Name: product_option_value product_option_value_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_option_value
    ADD CONSTRAINT product_option_value_pkey PRIMARY KEY (id);


--
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);


--
-- Name: product_sales_channel product_sales_channel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_sales_channel
    ADD CONSTRAINT product_sales_channel_pkey PRIMARY KEY (product_id, sales_channel_id);


--
-- Name: product_shipping_profile product_shipping_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_shipping_profile
    ADD CONSTRAINT product_shipping_profile_pkey PRIMARY KEY (product_id, shipping_profile_id);


--
-- Name: product_tag product_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_tag
    ADD CONSTRAINT product_tag_pkey PRIMARY KEY (id);


--
-- Name: product_tags product_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_tags
    ADD CONSTRAINT product_tags_pkey PRIMARY KEY (product_id, product_tag_id);


--
-- Name: product_type product_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_type
    ADD CONSTRAINT product_type_pkey PRIMARY KEY (id);


--
-- Name: product_variant_inventory_item product_variant_inventory_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variant_inventory_item
    ADD CONSTRAINT product_variant_inventory_item_pkey PRIMARY KEY (variant_id, inventory_item_id);


--
-- Name: product_variant_option product_variant_option_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variant_option
    ADD CONSTRAINT product_variant_option_pkey PRIMARY KEY (variant_id, option_value_id);


--
-- Name: product_variant product_variant_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variant
    ADD CONSTRAINT product_variant_pkey PRIMARY KEY (id);


--
-- Name: product_variant_price_set product_variant_price_set_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variant_price_set
    ADD CONSTRAINT product_variant_price_set_pkey PRIMARY KEY (variant_id, price_set_id);


--
-- Name: product_variant_product_image product_variant_product_image_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variant_product_image
    ADD CONSTRAINT product_variant_product_image_pkey PRIMARY KEY (id);


--
-- Name: promotion_application_method promotion_application_method_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_application_method
    ADD CONSTRAINT promotion_application_method_pkey PRIMARY KEY (id);


--
-- Name: promotion_campaign_budget promotion_campaign_budget_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_campaign_budget
    ADD CONSTRAINT promotion_campaign_budget_pkey PRIMARY KEY (id);


--
-- Name: promotion_campaign_budget_usage promotion_campaign_budget_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_campaign_budget_usage
    ADD CONSTRAINT promotion_campaign_budget_usage_pkey PRIMARY KEY (id);


--
-- Name: promotion_campaign promotion_campaign_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_campaign
    ADD CONSTRAINT promotion_campaign_pkey PRIMARY KEY (id);


--
-- Name: promotion promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_pkey PRIMARY KEY (id);


--
-- Name: promotion_promotion_rule promotion_promotion_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_promotion_rule
    ADD CONSTRAINT promotion_promotion_rule_pkey PRIMARY KEY (promotion_id, promotion_rule_id);


--
-- Name: promotion_rule promotion_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_rule
    ADD CONSTRAINT promotion_rule_pkey PRIMARY KEY (id);


--
-- Name: promotion_rule_value promotion_rule_value_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_rule_value
    ADD CONSTRAINT promotion_rule_value_pkey PRIMARY KEY (id);


--
-- Name: provider_identity provider_identity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_identity
    ADD CONSTRAINT provider_identity_pkey PRIMARY KEY (id);


--
-- Name: publishable_api_key_sales_channel publishable_api_key_sales_channel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publishable_api_key_sales_channel
    ADD CONSTRAINT publishable_api_key_sales_channel_pkey PRIMARY KEY (publishable_key_id, sales_channel_id);


--
-- Name: push_token push_token_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.push_token
    ADD CONSTRAINT push_token_pkey PRIMARY KEY (id);


--
-- Name: referral referral_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.referral
    ADD CONSTRAINT referral_pkey PRIMARY KEY (id);


--
-- Name: refund refund_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund
    ADD CONSTRAINT refund_pkey PRIMARY KEY (id);


--
-- Name: refund_reason refund_reason_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund_reason
    ADD CONSTRAINT refund_reason_pkey PRIMARY KEY (id);


--
-- Name: region_country region_country_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.region_country
    ADD CONSTRAINT region_country_pkey PRIMARY KEY (iso_2);


--
-- Name: region_payment_provider region_payment_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.region_payment_provider
    ADD CONSTRAINT region_payment_provider_pkey PRIMARY KEY (region_id, payment_provider_id);


--
-- Name: region region_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_pkey PRIMARY KEY (id);


--
-- Name: reservation_item reservation_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reservation_item
    ADD CONSTRAINT reservation_item_pkey PRIMARY KEY (id);


--
-- Name: return_fulfillment return_fulfillment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.return_fulfillment
    ADD CONSTRAINT return_fulfillment_pkey PRIMARY KEY (return_id, fulfillment_id);


--
-- Name: return_item return_item_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.return_item
    ADD CONSTRAINT return_item_pkey PRIMARY KEY (id);


--
-- Name: return return_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.return
    ADD CONSTRAINT return_pkey PRIMARY KEY (id);


--
-- Name: return_reason return_reason_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.return_reason
    ADD CONSTRAINT return_reason_pkey PRIMARY KEY (id);


--
-- Name: review review_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review
    ADD CONSTRAINT review_pkey PRIMARY KEY (id);


--
-- Name: sales_channel sales_channel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_channel
    ADD CONSTRAINT sales_channel_pkey PRIMARY KEY (id);


--
-- Name: sales_channel_stock_location sales_channel_stock_location_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sales_channel_stock_location
    ADD CONSTRAINT sales_channel_stock_location_pkey PRIMARY KEY (sales_channel_id, stock_location_id);


--
-- Name: script_migrations script_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.script_migrations
    ADD CONSTRAINT script_migrations_pkey PRIMARY KEY (id);


--
-- Name: service_zone service_zone_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_zone
    ADD CONSTRAINT service_zone_pkey PRIMARY KEY (id);


--
-- Name: shipping_option shipping_option_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_pkey PRIMARY KEY (id);


--
-- Name: shipping_option_price_set shipping_option_price_set_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_option_price_set
    ADD CONSTRAINT shipping_option_price_set_pkey PRIMARY KEY (shipping_option_id, price_set_id);


--
-- Name: shipping_option_rule shipping_option_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_option_rule
    ADD CONSTRAINT shipping_option_rule_pkey PRIMARY KEY (id);


--
-- Name: shipping_option_type shipping_option_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_option_type
    ADD CONSTRAINT shipping_option_type_pkey PRIMARY KEY (id);


--
-- Name: shipping_profile shipping_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_profile
    ADD CONSTRAINT shipping_profile_pkey PRIMARY KEY (id);


--
-- Name: short_video short_video_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.short_video
    ADD CONSTRAINT short_video_pkey PRIMARY KEY (id);


--
-- Name: stock_location_address stock_location_address_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_location_address
    ADD CONSTRAINT stock_location_address_pkey PRIMARY KEY (id);


--
-- Name: stock_location stock_location_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_location
    ADD CONSTRAINT stock_location_pkey PRIMARY KEY (id);


--
-- Name: store_currency store_currency_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.store_currency
    ADD CONSTRAINT store_currency_pkey PRIMARY KEY (id);


--
-- Name: store_locale store_locale_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.store_locale
    ADD CONSTRAINT store_locale_pkey PRIMARY KEY (id);


--
-- Name: store store_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.store
    ADD CONSTRAINT store_pkey PRIMARY KEY (id);


--
-- Name: tax_provider tax_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_provider
    ADD CONSTRAINT tax_provider_pkey PRIMARY KEY (id);


--
-- Name: tax_rate tax_rate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_rate
    ADD CONSTRAINT tax_rate_pkey PRIMARY KEY (id);


--
-- Name: tax_rate_rule tax_rate_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_rate_rule
    ADD CONSTRAINT tax_rate_rule_pkey PRIMARY KEY (id);


--
-- Name: tax_region tax_region_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_region
    ADD CONSTRAINT tax_region_pkey PRIMARY KEY (id);


--
-- Name: translation translation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.translation
    ADD CONSTRAINT translation_pkey PRIMARY KEY (id);


--
-- Name: translation_settings translation_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.translation_settings
    ADD CONSTRAINT translation_settings_pkey PRIMARY KEY (id);


--
-- Name: user_activity user_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_activity
    ADD CONSTRAINT user_activity_pkey PRIMARY KEY (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: user_preference user_preference_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_preference
    ADD CONSTRAINT user_preference_pkey PRIMARY KEY (id);


--
-- Name: user_rbac_role user_rbac_role_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_rbac_role
    ADD CONSTRAINT user_rbac_role_pkey PRIMARY KEY (user_id, rbac_role_id);


--
-- Name: vendor_admin vendor_admin_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_admin
    ADD CONSTRAINT vendor_admin_pkey PRIMARY KEY (id);


--
-- Name: vendor_follow vendor_follow_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_follow
    ADD CONSTRAINT vendor_follow_pkey PRIMARY KEY (id);


--
-- Name: vendor_payout vendor_payout_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_payout
    ADD CONSTRAINT vendor_payout_pkey PRIMARY KEY (id);


--
-- Name: vendor vendor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor
    ADD CONSTRAINT vendor_pkey PRIMARY KEY (id);


--
-- Name: video_comment video_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.video_comment
    ADD CONSTRAINT video_comment_pkey PRIMARY KEY (id);


--
-- Name: video_like video_like_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.video_like
    ADD CONSTRAINT video_like_pkey PRIMARY KEY (id);


--
-- Name: video_save video_save_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.video_save
    ADD CONSTRAINT video_save_pkey PRIMARY KEY (id);


--
-- Name: view_configuration view_configuration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.view_configuration
    ADD CONSTRAINT view_configuration_pkey PRIMARY KEY (id);


--
-- Name: wheel_prize wheel_prize_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wheel_prize
    ADD CONSTRAINT wheel_prize_pkey PRIMARY KEY (id);


--
-- Name: wheel_spin wheel_spin_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wheel_spin
    ADD CONSTRAINT wheel_spin_pkey PRIMARY KEY (id);


--
-- Name: workflow_execution workflow_execution_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_execution
    ADD CONSTRAINT workflow_execution_pkey PRIMARY KEY (workflow_id, transaction_id, run_id);


--
-- Name: IDX_account_holder_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_account_holder_deleted_at" ON public.account_holder USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_account_holder_id_5cb3a0c0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_account_holder_id_5cb3a0c0" ON public.customer_account_holder USING btree (account_holder_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_account_holder_provider_id_external_id_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_account_holder_provider_id_external_id_unique" ON public.account_holder USING btree (provider_id, external_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_analytics_event_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_analytics_event_deleted_at" ON public.analytics_event USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_api_key_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_api_key_deleted_at" ON public.api_key USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_api_key_redacted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_api_key_redacted" ON public.api_key USING btree (redacted) WHERE (deleted_at IS NULL);


--
-- Name: IDX_api_key_revoked_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_api_key_revoked_at" ON public.api_key USING btree (revoked_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_api_key_token_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_api_key_token_unique" ON public.api_key USING btree (token);


--
-- Name: IDX_api_key_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_api_key_type" ON public.api_key USING btree (type);


--
-- Name: IDX_app_notification_recipient; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_app_notification_recipient" ON public.app_notification USING btree (recipient_id, is_read, created_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_application_method_allocation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_application_method_allocation" ON public.promotion_application_method USING btree (allocation);


--
-- Name: IDX_application_method_target_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_application_method_target_type" ON public.promotion_application_method USING btree (target_type);


--
-- Name: IDX_application_method_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_application_method_type" ON public.promotion_application_method USING btree (type);


--
-- Name: IDX_auth_identity_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_auth_identity_deleted_at" ON public.auth_identity USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_campaign_budget_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_campaign_budget_type" ON public.promotion_campaign_budget USING btree (type);


--
-- Name: IDX_capture_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_capture_deleted_at" ON public.capture USING btree (deleted_at);


--
-- Name: IDX_capture_payment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_capture_payment_id" ON public.capture USING btree (payment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_address_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_address_deleted_at" ON public.cart_address USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_billing_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_billing_address_id" ON public.cart USING btree (billing_address_id) WHERE ((deleted_at IS NULL) AND (billing_address_id IS NOT NULL));


--
-- Name: IDX_cart_credit_line_reference_reference_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_credit_line_reference_reference_id" ON public.credit_line USING btree (reference, reference_id) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_currency_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_currency_code" ON public.cart USING btree (currency_code);


--
-- Name: IDX_cart_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_customer_id" ON public.cart USING btree (customer_id) WHERE ((deleted_at IS NULL) AND (customer_id IS NOT NULL));


--
-- Name: IDX_cart_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_deleted_at" ON public.cart USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_id_-4a39f6c9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_id_-4a39f6c9" ON public.cart_payment_collection USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_id_-71069c16; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_id_-71069c16" ON public.order_cart USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_id_-a9d4a70b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_id_-a9d4a70b" ON public.cart_promotion USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_line_item_adjustment_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_line_item_adjustment_deleted_at" ON public.cart_line_item_adjustment USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_line_item_adjustment_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_line_item_adjustment_item_id" ON public.cart_line_item_adjustment USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_line_item_cart_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_line_item_cart_id" ON public.cart_line_item USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_line_item_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_line_item_deleted_at" ON public.cart_line_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_line_item_tax_line_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_line_item_tax_line_deleted_at" ON public.cart_line_item_tax_line USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_line_item_tax_line_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_line_item_tax_line_item_id" ON public.cart_line_item_tax_line USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_region_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_region_id" ON public.cart USING btree (region_id) WHERE ((deleted_at IS NULL) AND (region_id IS NOT NULL));


--
-- Name: IDX_cart_sales_channel_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_sales_channel_id" ON public.cart USING btree (sales_channel_id) WHERE ((deleted_at IS NULL) AND (sales_channel_id IS NOT NULL));


--
-- Name: IDX_cart_shipping_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_shipping_address_id" ON public.cart USING btree (shipping_address_id) WHERE ((deleted_at IS NULL) AND (shipping_address_id IS NOT NULL));


--
-- Name: IDX_cart_shipping_method_adjustment_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_shipping_method_adjustment_deleted_at" ON public.cart_shipping_method_adjustment USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_shipping_method_adjustment_shipping_method_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_shipping_method_adjustment_shipping_method_id" ON public.cart_shipping_method_adjustment USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_shipping_method_cart_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_shipping_method_cart_id" ON public.cart_shipping_method USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_shipping_method_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_shipping_method_deleted_at" ON public.cart_shipping_method USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_shipping_method_tax_line_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_shipping_method_tax_line_deleted_at" ON public.cart_shipping_method_tax_line USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_shipping_method_tax_line_shipping_method_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_cart_shipping_method_tax_line_shipping_method_id" ON public.cart_shipping_method_tax_line USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_category_handle_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_category_handle_unique" ON public.product_category USING btree (handle) WHERE (deleted_at IS NULL);


--
-- Name: IDX_collection_handle_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_collection_handle_unique" ON public.product_collection USING btree (handle) WHERE (deleted_at IS NULL);


--
-- Name: IDX_conversation_broadcast_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_conversation_broadcast_unique" ON public.conversation USING btree (vendor_id) WHERE ((type = 'broadcast'::text) AND (deleted_at IS NULL));


--
-- Name: IDX_conversation_customer_vendor; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_conversation_customer_vendor" ON public.conversation USING btree (customer_id, vendor_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_conversation_customer_vendor_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_conversation_customer_vendor_unique" ON public.conversation USING btree (customer_id, vendor_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_credit_line_cart_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_credit_line_cart_id" ON public.credit_line USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_credit_line_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_credit_line_deleted_at" ON public.credit_line USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_address_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_customer_address_customer_id" ON public.customer_address USING btree (customer_id);


--
-- Name: IDX_customer_address_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_customer_address_deleted_at" ON public.customer_address USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_address_unique_customer_billing; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_customer_address_unique_customer_billing" ON public.customer_address USING btree (customer_id) WHERE (is_default_billing = true);


--
-- Name: IDX_customer_address_unique_customer_shipping; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_customer_address_unique_customer_shipping" ON public.customer_address USING btree (customer_id) WHERE (is_default_shipping = true);


--
-- Name: IDX_customer_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_customer_deleted_at" ON public.customer USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_email_has_account_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_customer_email_has_account_unique" ON public.customer USING btree (email, has_account) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_customer_customer_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_customer_group_customer_customer_group_id" ON public.customer_group_customer USING btree (customer_group_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_customer_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_customer_group_customer_customer_id" ON public.customer_group_customer USING btree (customer_id);


--
-- Name: IDX_customer_group_customer_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_customer_group_customer_deleted_at" ON public.customer_group_customer USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_customer_group_deleted_at" ON public.customer_group USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_name_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_customer_group_name_unique" ON public.customer_group USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_id_5cb3a0c0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_customer_id_5cb3a0c0" ON public.customer_account_holder USING btree (customer_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_loyalty_customer_id_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_customer_loyalty_customer_id_unique" ON public.customer_loyalty USING btree (customer_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_loyalty_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_customer_loyalty_deleted_at" ON public.customer_loyalty USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_loyalty_referral_code_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_customer_loyalty_referral_code_unique" ON public.customer_loyalty USING btree (referral_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_payment_method_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_customer_payment_method_customer_id" ON public.customer_payment_method USING btree (customer_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_daily_check_in_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_daily_check_in_deleted_at" ON public.daily_check_in USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_daily_check_in_loyalty_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_daily_check_in_loyalty_id" ON public.daily_check_in USING btree (loyalty_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_deleted_at_-12e0822f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_-12e0822f" ON public.marketplace_vendor_order_order USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-1d67bae40; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_-1d67bae40" ON public.publishable_api_key_sales_channel USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-1e5992737; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_-1e5992737" ON public.location_fulfillment_provider USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-31ea43a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_-31ea43a" ON public.return_fulfillment USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-4a39f6c9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_-4a39f6c9" ON public.cart_payment_collection USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-71069c16; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_-71069c16" ON public.order_cart USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-71518339; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_-71518339" ON public.order_promotion USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-a9d4a70b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_-a9d4a70b" ON public.cart_promotion USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-d14c9099; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_-d14c9099" ON public.marketplace_vendor_promotion_promotion USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-e88adb96; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_-e88adb96" ON public.location_fulfillment_set USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-e8d2543e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_-e8d2543e" ON public.order_fulfillment USING btree (deleted_at);


--
-- Name: IDX_deleted_at_155848331; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_155848331" ON public.marketplace_vendor_stock_location_stock_location USING btree (deleted_at);


--
-- Name: IDX_deleted_at_17a262437; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_17a262437" ON public.product_shipping_profile USING btree (deleted_at);


--
-- Name: IDX_deleted_at_17b4c4e35; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_17b4c4e35" ON public.product_variant_inventory_item USING btree (deleted_at);


--
-- Name: IDX_deleted_at_1c934dab0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_1c934dab0" ON public.region_payment_provider USING btree (deleted_at);


--
-- Name: IDX_deleted_at_20b454295; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_20b454295" ON public.product_sales_channel USING btree (deleted_at);


--
-- Name: IDX_deleted_at_227c36b1c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_227c36b1c" ON public.delivery_delivery_company_fulfillment_shipping_option USING btree (deleted_at);


--
-- Name: IDX_deleted_at_26d06f470; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_26d06f470" ON public.sales_channel_stock_location USING btree (deleted_at);


--
-- Name: IDX_deleted_at_3ca1b85b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_3ca1b85b" ON public.marketplace_vendor_product_product USING btree (deleted_at);


--
-- Name: IDX_deleted_at_52b23597; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_52b23597" ON public.product_variant_price_set USING btree (deleted_at);


--
-- Name: IDX_deleted_at_5cb3a0c0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_5cb3a0c0" ON public.customer_account_holder USING btree (deleted_at);


--
-- Name: IDX_deleted_at_64ff0c4c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_64ff0c4c" ON public.user_rbac_role USING btree (deleted_at);


--
-- Name: IDX_deleted_at_ba32fa9c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_ba32fa9c" ON public.shipping_option_price_set USING btree (deleted_at);


--
-- Name: IDX_deleted_at_f42b9949; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_deleted_at_f42b9949" ON public.order_payment_collection USING btree (deleted_at);


--
-- Name: IDX_delivery_company_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_delivery_company_deleted_at" ON public.delivery_company USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_delivery_company_email_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_delivery_company_email_unique" ON public.delivery_company USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: IDX_delivery_company_id_227c36b1c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_delivery_company_id_227c36b1c" ON public.delivery_delivery_company_fulfillment_shipping_option USING btree (delivery_company_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_delivery_driver_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_delivery_driver_deleted_at" ON public.delivery_driver USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_delivery_driver_delivery_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_delivery_driver_delivery_company_id" ON public.delivery_driver USING btree (delivery_company_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_flash_sale_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_flash_sale_deleted_at" ON public.flash_sale USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_address_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_address_deleted_at" ON public.fulfillment_address USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_deleted_at" ON public.fulfillment USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_id_-31ea43a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_id_-31ea43a" ON public.return_fulfillment USING btree (fulfillment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_id_-e8d2543e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_id_-e8d2543e" ON public.order_fulfillment USING btree (fulfillment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_item_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_item_deleted_at" ON public.fulfillment_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_item_fulfillment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_item_fulfillment_id" ON public.fulfillment_item USING btree (fulfillment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_item_inventory_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_item_inventory_item_id" ON public.fulfillment_item USING btree (inventory_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_item_line_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_item_line_item_id" ON public.fulfillment_item USING btree (line_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_label_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_label_deleted_at" ON public.fulfillment_label USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_label_fulfillment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_label_fulfillment_id" ON public.fulfillment_label USING btree (fulfillment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_location_id" ON public.fulfillment USING btree (location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_provider_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_provider_deleted_at" ON public.fulfillment_provider USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_provider_id_-1e5992737; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_provider_id_-1e5992737" ON public.location_fulfillment_provider USING btree (fulfillment_provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_set_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_set_deleted_at" ON public.fulfillment_set USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_set_id_-e88adb96; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_set_id_-e88adb96" ON public.location_fulfillment_set USING btree (fulfillment_set_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_set_name_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_fulfillment_set_name_unique" ON public.fulfillment_set USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_shipping_option_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_fulfillment_shipping_option_id" ON public.fulfillment USING btree (shipping_option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_geo_zone_city; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_geo_zone_city" ON public.geo_zone USING btree (city) WHERE ((deleted_at IS NULL) AND (city IS NOT NULL));


--
-- Name: IDX_geo_zone_country_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_geo_zone_country_code" ON public.geo_zone USING btree (country_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_geo_zone_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_geo_zone_deleted_at" ON public.geo_zone USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_geo_zone_province_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_geo_zone_province_code" ON public.geo_zone USING btree (province_code) WHERE ((deleted_at IS NULL) AND (province_code IS NOT NULL));


--
-- Name: IDX_geo_zone_service_zone_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_geo_zone_service_zone_id" ON public.geo_zone USING btree (service_zone_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_id_-12e0822f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_-12e0822f" ON public.marketplace_vendor_order_order USING btree (id);


--
-- Name: IDX_id_-1d67bae40; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_-1d67bae40" ON public.publishable_api_key_sales_channel USING btree (id);


--
-- Name: IDX_id_-1e5992737; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_-1e5992737" ON public.location_fulfillment_provider USING btree (id);


--
-- Name: IDX_id_-31ea43a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_-31ea43a" ON public.return_fulfillment USING btree (id);


--
-- Name: IDX_id_-4a39f6c9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_-4a39f6c9" ON public.cart_payment_collection USING btree (id);


--
-- Name: IDX_id_-71069c16; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_-71069c16" ON public.order_cart USING btree (id);


--
-- Name: IDX_id_-71518339; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_-71518339" ON public.order_promotion USING btree (id);


--
-- Name: IDX_id_-a9d4a70b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_-a9d4a70b" ON public.cart_promotion USING btree (id);


--
-- Name: IDX_id_-d14c9099; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_-d14c9099" ON public.marketplace_vendor_promotion_promotion USING btree (id);


--
-- Name: IDX_id_-e88adb96; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_-e88adb96" ON public.location_fulfillment_set USING btree (id);


--
-- Name: IDX_id_-e8d2543e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_-e8d2543e" ON public.order_fulfillment USING btree (id);


--
-- Name: IDX_id_155848331; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_155848331" ON public.marketplace_vendor_stock_location_stock_location USING btree (id);


--
-- Name: IDX_id_17a262437; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_17a262437" ON public.product_shipping_profile USING btree (id);


--
-- Name: IDX_id_17b4c4e35; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_17b4c4e35" ON public.product_variant_inventory_item USING btree (id);


--
-- Name: IDX_id_1c934dab0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_1c934dab0" ON public.region_payment_provider USING btree (id);


--
-- Name: IDX_id_20b454295; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_20b454295" ON public.product_sales_channel USING btree (id);


--
-- Name: IDX_id_227c36b1c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_227c36b1c" ON public.delivery_delivery_company_fulfillment_shipping_option USING btree (id);


--
-- Name: IDX_id_26d06f470; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_26d06f470" ON public.sales_channel_stock_location USING btree (id);


--
-- Name: IDX_id_3ca1b85b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_3ca1b85b" ON public.marketplace_vendor_product_product USING btree (id);


--
-- Name: IDX_id_52b23597; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_52b23597" ON public.product_variant_price_set USING btree (id);


--
-- Name: IDX_id_5cb3a0c0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_5cb3a0c0" ON public.customer_account_holder USING btree (id);


--
-- Name: IDX_id_64ff0c4c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_64ff0c4c" ON public.user_rbac_role USING btree (id);


--
-- Name: IDX_id_ba32fa9c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_ba32fa9c" ON public.shipping_option_price_set USING btree (id);


--
-- Name: IDX_id_f42b9949; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_id_f42b9949" ON public.order_payment_collection USING btree (id);


--
-- Name: IDX_image_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_image_deleted_at" ON public.image USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_image_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_image_product_id" ON public.image USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_item_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_inventory_item_deleted_at" ON public.inventory_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_inventory_item_id_17b4c4e35; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_inventory_item_id_17b4c4e35" ON public.product_variant_inventory_item USING btree (inventory_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_item_sku; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_inventory_item_sku" ON public.inventory_item USING btree (sku) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_level_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_inventory_level_deleted_at" ON public.inventory_level USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_inventory_level_inventory_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_inventory_level_inventory_item_id" ON public.inventory_level USING btree (inventory_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_level_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_inventory_level_location_id" ON public.inventory_level USING btree (location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_level_location_id_inventory_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_inventory_level_location_id_inventory_item_id" ON public.inventory_level USING btree (inventory_item_id, location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_invite_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_invite_deleted_at" ON public.invite USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_invite_email_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_invite_email_unique" ON public.invite USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: IDX_invite_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_invite_token" ON public.invite USING btree (token) WHERE (deleted_at IS NULL);


--
-- Name: IDX_line_item_adjustment_promotion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_line_item_adjustment_promotion_id" ON public.cart_line_item_adjustment USING btree (promotion_id) WHERE ((deleted_at IS NULL) AND (promotion_id IS NOT NULL));


--
-- Name: IDX_line_item_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_line_item_product_id" ON public.cart_line_item USING btree (product_id) WHERE ((deleted_at IS NULL) AND (product_id IS NOT NULL));


--
-- Name: IDX_line_item_product_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_line_item_product_type_id" ON public.order_line_item USING btree (product_type_id) WHERE ((deleted_at IS NULL) AND (product_type_id IS NOT NULL));


--
-- Name: IDX_line_item_tax_line_tax_rate_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_line_item_tax_line_tax_rate_id" ON public.cart_line_item_tax_line USING btree (tax_rate_id) WHERE ((deleted_at IS NULL) AND (tax_rate_id IS NOT NULL));


--
-- Name: IDX_line_item_variant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_line_item_variant_id" ON public.cart_line_item USING btree (variant_id) WHERE ((deleted_at IS NULL) AND (variant_id IS NOT NULL));


--
-- Name: IDX_locale_code_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_locale_code_unique" ON public.locale USING btree (code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_locale_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_locale_deleted_at" ON public.locale USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_loyalty_coupon_code_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_loyalty_coupon_code_unique" ON public.loyalty_coupon USING btree (code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_loyalty_coupon_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_loyalty_coupon_customer_id" ON public.loyalty_coupon USING btree (customer_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_loyalty_coupon_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_loyalty_coupon_deleted_at" ON public.loyalty_coupon USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_loyalty_transaction_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_loyalty_transaction_customer_id" ON public.loyalty_transaction USING btree (customer_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_loyalty_transaction_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_loyalty_transaction_deleted_at" ON public.loyalty_transaction USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_message_conversation_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_message_conversation_created" ON public.message USING btree (conversation_id, created_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_message_conversation_is_read; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_message_conversation_is_read" ON public.message USING btree (conversation_id, is_read) WHERE (deleted_at IS NULL);


--
-- Name: IDX_notification_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_notification_deleted_at" ON public.notification USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_notification_idempotency_key_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_notification_idempotency_key_unique" ON public.notification USING btree (idempotency_key) WHERE (deleted_at IS NULL);


--
-- Name: IDX_notification_preference_recipient; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_notification_preference_recipient" ON public.notification_preference USING btree (recipient_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_notification_provider_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_notification_provider_deleted_at" ON public.notification_provider USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_notification_provider_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_notification_provider_id" ON public.notification USING btree (provider_id);


--
-- Name: IDX_notification_receiver_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_notification_receiver_id" ON public.notification USING btree (receiver_id);


--
-- Name: IDX_option_product_id_title_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_option_product_id_title_unique" ON public.product_option USING btree (product_id, title) WHERE (deleted_at IS NULL);


--
-- Name: IDX_option_value_option_id_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_option_value_option_id_unique" ON public.product_option_value USING btree (option_id, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_address_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_address_customer_id" ON public.order_address USING btree (customer_id);


--
-- Name: IDX_order_address_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_address_deleted_at" ON public.order_address USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_billing_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_billing_address_id" ON public."order" USING btree (billing_address_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_action_claim_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_action_claim_id" ON public.order_change_action USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_action_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_action_deleted_at" ON public.order_change_action USING btree (deleted_at);


--
-- Name: IDX_order_change_action_exchange_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_action_exchange_id" ON public.order_change_action USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_action_order_change_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_action_order_change_id" ON public.order_change_action USING btree (order_change_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_action_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_action_order_id" ON public.order_change_action USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_action_ordering; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_action_ordering" ON public.order_change_action USING btree (ordering) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_action_return_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_action_return_id" ON public.order_change_action USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_change_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_change_type" ON public.order_change USING btree (change_type);


--
-- Name: IDX_order_change_claim_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_claim_id" ON public.order_change USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_deleted_at" ON public.order_change USING btree (deleted_at);


--
-- Name: IDX_order_change_exchange_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_exchange_id" ON public.order_change USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_order_id" ON public.order_change USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_order_id_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_order_id_version" ON public.order_change USING btree (order_id, version);


--
-- Name: IDX_order_change_return_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_return_id" ON public.order_change USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_status" ON public.order_change USING btree (status) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_change_version" ON public.order_change USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_claim_deleted_at" ON public.order_claim USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_display_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_claim_display_id" ON public.order_claim USING btree (display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_item_claim_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_claim_item_claim_id" ON public.order_claim_item USING btree (claim_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_item_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_claim_item_deleted_at" ON public.order_claim_item USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_item_image_claim_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_claim_item_image_claim_item_id" ON public.order_claim_item_image USING btree (claim_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_item_image_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_claim_item_image_deleted_at" ON public.order_claim_item_image USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_claim_item_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_claim_item_item_id" ON public.order_claim_item USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_claim_order_id" ON public.order_claim USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_return_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_claim_return_id" ON public.order_claim USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_credit_line_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_credit_line_deleted_at" ON public.order_credit_line USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_credit_line_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_credit_line_order_id" ON public.order_credit_line USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_credit_line_order_id_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_credit_line_order_id_version" ON public.order_credit_line USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_currency_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_currency_code" ON public."order" USING btree (currency_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_custom_display_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_order_custom_display_id" ON public."order" USING btree (custom_display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_customer_id" ON public."order" USING btree (customer_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_deleted_at" ON public."order" USING btree (deleted_at);


--
-- Name: IDX_order_display_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_display_id" ON public."order" USING btree (display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_exchange_deleted_at" ON public.order_exchange USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_display_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_exchange_display_id" ON public.order_exchange USING btree (display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_item_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_exchange_item_deleted_at" ON public.order_exchange_item USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_item_exchange_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_exchange_item_exchange_id" ON public.order_exchange_item USING btree (exchange_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_item_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_exchange_item_item_id" ON public.order_exchange_item USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_exchange_order_id" ON public.order_exchange USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_return_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_exchange_return_id" ON public.order_exchange USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_id_-12e0822f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_id_-12e0822f" ON public.marketplace_vendor_order_order USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_id_-71069c16; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_id_-71069c16" ON public.order_cart USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_id_-71518339; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_id_-71518339" ON public.order_promotion USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_id_-e8d2543e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_id_-e8d2543e" ON public.order_fulfillment USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_id_f42b9949; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_id_f42b9949" ON public.order_payment_collection USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_is_draft_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_is_draft_order" ON public."order" USING btree (is_draft_order) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_item_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_item_deleted_at" ON public.order_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_item_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_item_item_id" ON public.order_item USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_item_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_item_order_id" ON public.order_item USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_item_order_id_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_item_order_id_version" ON public.order_item USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_line_item_adjustment_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_line_item_adjustment_item_id" ON public.order_line_item_adjustment USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_line_item_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_line_item_product_id" ON public.order_line_item USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_line_item_tax_line_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_line_item_tax_line_item_id" ON public.order_line_item_tax_line USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_line_item_variant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_line_item_variant_id" ON public.order_line_item USING btree (variant_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_region_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_region_id" ON public."order" USING btree (region_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_sales_channel_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_sales_channel_id" ON public."order" USING btree (sales_channel_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_shipping_address_id" ON public."order" USING btree (shipping_address_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_claim_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_shipping_claim_id" ON public.order_shipping USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_shipping_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_shipping_deleted_at" ON public.order_shipping USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_shipping_exchange_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_shipping_exchange_id" ON public.order_shipping USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_shipping_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_shipping_item_id" ON public.order_shipping USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_method_adjustment_shipping_method_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_shipping_method_adjustment_shipping_method_id" ON public.order_shipping_method_adjustment USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_method_shipping_option_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_shipping_method_shipping_option_id" ON public.order_shipping_method USING btree (shipping_option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_method_tax_line_shipping_method_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_shipping_method_tax_line_shipping_method_id" ON public.order_shipping_method_tax_line USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_shipping_order_id" ON public.order_shipping USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_order_id_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_shipping_order_id_version" ON public.order_shipping USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_return_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_shipping_return_id" ON public.order_shipping USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_shipping_shipping_method_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_shipping_shipping_method_id" ON public.order_shipping USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_summary_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_summary_deleted_at" ON public.order_summary USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_summary_order_id_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_summary_order_id_version" ON public.order_summary USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_claim_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_transaction_claim_id" ON public.order_transaction USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_transaction_currency_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_transaction_currency_code" ON public.order_transaction USING btree (currency_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_exchange_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_transaction_exchange_id" ON public.order_transaction USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_transaction_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_transaction_order_id" ON public.order_transaction USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_order_id_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_transaction_order_id_version" ON public.order_transaction USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_reference_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_transaction_reference_id" ON public.order_transaction USING btree (reference_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_return_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_order_transaction_return_id" ON public.order_transaction USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_payment_collection_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_payment_collection_deleted_at" ON public.payment_collection USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_payment_collection_id_-4a39f6c9; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_payment_collection_id_-4a39f6c9" ON public.cart_payment_collection USING btree (payment_collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_collection_id_f42b9949; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_payment_collection_id_f42b9949" ON public.order_payment_collection USING btree (payment_collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_payment_deleted_at" ON public.payment USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_payment_payment_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_payment_payment_collection_id" ON public.payment USING btree (payment_collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_payment_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_payment_payment_session_id" ON public.payment USING btree (payment_session_id);


--
-- Name: IDX_payment_payment_session_id_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_payment_payment_session_id_unique" ON public.payment USING btree (payment_session_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_provider_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_payment_provider_deleted_at" ON public.payment_provider USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_provider_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_payment_provider_id" ON public.payment USING btree (provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_provider_id_1c934dab0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_payment_provider_id_1c934dab0" ON public.region_payment_provider USING btree (payment_provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_session_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_payment_session_deleted_at" ON public.payment_session USING btree (deleted_at);


--
-- Name: IDX_payment_session_payment_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_payment_session_payment_collection_id" ON public.payment_session USING btree (payment_collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_currency_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_currency_code" ON public.price USING btree (currency_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_deleted_at" ON public.price USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_list_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_list_deleted_at" ON public.price_list USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_list_id_status_starts_at_ends_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_list_id_status_starts_at_ends_at" ON public.price_list USING btree (id, status, starts_at, ends_at) WHERE ((deleted_at IS NULL) AND (status = 'active'::text));


--
-- Name: IDX_price_list_rule_attribute; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_list_rule_attribute" ON public.price_list_rule USING btree (attribute) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_list_rule_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_list_rule_deleted_at" ON public.price_list_rule USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_list_rule_price_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_list_rule_price_list_id" ON public.price_list_rule USING btree (price_list_id) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_list_rule_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_list_rule_value" ON public.price_list_rule USING gin (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_preference_attribute_value; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_price_preference_attribute_value" ON public.price_preference USING btree (attribute, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_preference_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_preference_deleted_at" ON public.price_preference USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_price_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_price_list_id" ON public.price USING btree (price_list_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_price_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_price_set_id" ON public.price USING btree (price_set_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_attribute; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_rule_attribute" ON public.price_rule USING btree (attribute) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_attribute_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_rule_attribute_value" ON public.price_rule USING btree (attribute, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_attribute_value_price_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_rule_attribute_value_price_id" ON public.price_rule USING btree (attribute, value, price_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_rule_deleted_at" ON public.price_rule USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_rule_operator; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_rule_operator" ON public.price_rule USING btree (operator);


--
-- Name: IDX_price_rule_operator_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_rule_operator_value" ON public.price_rule USING btree (operator, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_price_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_rule_price_id" ON public.price_rule USING btree (price_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_price_id_attribute_operator_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_price_rule_price_id_attribute_operator_unique" ON public.price_rule USING btree (price_id, attribute, operator) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_set_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_set_deleted_at" ON public.price_set USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_set_id_52b23597; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_set_id_52b23597" ON public.product_variant_price_set USING btree (price_set_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_set_id_ba32fa9c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_price_set_id_ba32fa9c" ON public.shipping_option_price_set USING btree (price_set_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_category_parent_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_category_parent_category_id" ON public.product_category USING btree (parent_category_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_category_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_category_path" ON public.product_category USING btree (mpath) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_collection_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_collection_deleted_at" ON public.product_collection USING btree (deleted_at);


--
-- Name: IDX_product_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_collection_id" ON public.product USING btree (collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_deleted_at" ON public.product USING btree (deleted_at);


--
-- Name: IDX_product_handle_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_product_handle_unique" ON public.product USING btree (handle) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_id_17a262437; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_id_17a262437" ON public.product_shipping_profile USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_id_20b454295; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_id_20b454295" ON public.product_sales_channel USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_id_3ca1b85b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_id_3ca1b85b" ON public.marketplace_vendor_product_product USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_image_rank; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_image_rank" ON public.image USING btree (rank) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_image_rank_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_image_rank_product_id" ON public.image USING btree (rank, product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_image_url; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_image_url" ON public.image USING btree (url) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_image_url_rank_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_image_url_rank_product_id" ON public.image USING btree (url, rank, product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_option_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_option_deleted_at" ON public.product_option USING btree (deleted_at);


--
-- Name: IDX_product_option_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_option_product_id" ON public.product_option USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_option_value_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_option_value_deleted_at" ON public.product_option_value USING btree (deleted_at);


--
-- Name: IDX_product_option_value_option_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_option_value_option_id" ON public.product_option_value USING btree (option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_status" ON public.product USING btree (status) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_tag_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_tag_deleted_at" ON public.product_tag USING btree (deleted_at);


--
-- Name: IDX_product_type_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_type_deleted_at" ON public.product_type USING btree (deleted_at);


--
-- Name: IDX_product_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_type_id" ON public.product USING btree (type_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_barcode_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_product_variant_barcode_unique" ON public.product_variant USING btree (barcode) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_variant_deleted_at" ON public.product_variant USING btree (deleted_at);


--
-- Name: IDX_product_variant_ean_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_product_variant_ean_unique" ON public.product_variant USING btree (ean) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_id_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_variant_id_product_id" ON public.product_variant USING btree (id, product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_variant_product_id" ON public.product_variant USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_product_image_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_variant_product_image_deleted_at" ON public.product_variant_product_image USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_product_image_image_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_variant_product_image_image_id" ON public.product_variant_product_image USING btree (image_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_product_image_variant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_product_variant_product_image_variant_id" ON public.product_variant_product_image USING btree (variant_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_sku_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_product_variant_sku_unique" ON public.product_variant USING btree (sku) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_upc_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_product_variant_upc_unique" ON public.product_variant USING btree (upc) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_application_method_currency_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_application_method_currency_code" ON public.promotion_application_method USING btree (currency_code) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_promotion_application_method_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_application_method_deleted_at" ON public.promotion_application_method USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_application_method_promotion_id_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_promotion_application_method_promotion_id_unique" ON public.promotion_application_method USING btree (promotion_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_budget_campaign_id_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_promotion_campaign_budget_campaign_id_unique" ON public.promotion_campaign_budget USING btree (campaign_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_budget_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_campaign_budget_deleted_at" ON public.promotion_campaign_budget USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_budget_usage_attribute_value_budget_id_u; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_promotion_campaign_budget_usage_attribute_value_budget_id_u" ON public.promotion_campaign_budget_usage USING btree (attribute_value, budget_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_budget_usage_budget_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_campaign_budget_usage_budget_id" ON public.promotion_campaign_budget_usage USING btree (budget_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_budget_usage_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_campaign_budget_usage_deleted_at" ON public.promotion_campaign_budget_usage USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_campaign_identifier_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_promotion_campaign_campaign_identifier_unique" ON public.promotion_campaign USING btree (campaign_identifier) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_campaign_deleted_at" ON public.promotion_campaign USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_campaign_id" ON public.promotion USING btree (campaign_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_deleted_at" ON public.promotion USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_id_-71518339; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_id_-71518339" ON public.order_promotion USING btree (promotion_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_id_-a9d4a70b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_id_-a9d4a70b" ON public.cart_promotion USING btree (promotion_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_id_-d14c9099; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_id_-d14c9099" ON public.marketplace_vendor_promotion_promotion USING btree (promotion_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_is_automatic; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_is_automatic" ON public.promotion USING btree (is_automatic) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_attribute; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_rule_attribute" ON public.promotion_rule USING btree (attribute);


--
-- Name: IDX_promotion_rule_attribute_operator; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_rule_attribute_operator" ON public.promotion_rule USING btree (attribute, operator) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_attribute_operator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_rule_attribute_operator_id" ON public.promotion_rule USING btree (operator, attribute, id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_rule_deleted_at" ON public.promotion_rule USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_operator; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_rule_operator" ON public.promotion_rule USING btree (operator);


--
-- Name: IDX_promotion_rule_value_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_rule_value_deleted_at" ON public.promotion_rule_value USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_value_promotion_rule_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_rule_value_promotion_rule_id" ON public.promotion_rule_value USING btree (promotion_rule_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_value_rule_id_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_rule_value_rule_id_value" ON public.promotion_rule_value USING btree (promotion_rule_id, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_value_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_rule_value_value" ON public.promotion_rule_value USING btree (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_status" ON public.promotion USING btree (status) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_promotion_type" ON public.promotion USING btree (type);


--
-- Name: IDX_provider_identity_auth_identity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_provider_identity_auth_identity_id" ON public.provider_identity USING btree (auth_identity_id);


--
-- Name: IDX_provider_identity_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_provider_identity_deleted_at" ON public.provider_identity USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_provider_identity_provider_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_provider_identity_provider_entity_id" ON public.provider_identity USING btree (entity_id, provider);


--
-- Name: IDX_publishable_key_id_-1d67bae40; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_publishable_key_id_-1d67bae40" ON public.publishable_api_key_sales_channel USING btree (publishable_key_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_push_token_recipient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_push_token_recipient_id" ON public.push_token USING btree (recipient_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_rbac_role_id_64ff0c4c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_rbac_role_id_64ff0c4c" ON public.user_rbac_role USING btree (rbac_role_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_referral_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_referral_deleted_at" ON public.referral USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_referral_referred_customer_id_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_referral_referred_customer_id_unique" ON public.referral USING btree (referred_customer_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_referral_referrer_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_referral_referrer_customer_id" ON public.referral USING btree (referrer_customer_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_refund_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_refund_deleted_at" ON public.refund USING btree (deleted_at);


--
-- Name: IDX_refund_payment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_refund_payment_id" ON public.refund USING btree (payment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_refund_reason_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_refund_reason_deleted_at" ON public.refund_reason USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_refund_refund_reason_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_refund_refund_reason_id" ON public.refund USING btree (refund_reason_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_region_country_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_region_country_deleted_at" ON public.region_country USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_region_country_region_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_region_country_region_id" ON public.region_country USING btree (region_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_region_country_region_id_iso_2_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_region_country_region_id_iso_2_unique" ON public.region_country USING btree (region_id, iso_2);


--
-- Name: IDX_region_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_region_deleted_at" ON public.region USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_region_id_1c934dab0; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_region_id_1c934dab0" ON public.region_payment_provider USING btree (region_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_reservation_item_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_reservation_item_deleted_at" ON public.reservation_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_reservation_item_inventory_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_reservation_item_inventory_item_id" ON public.reservation_item USING btree (inventory_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_reservation_item_line_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_reservation_item_line_item_id" ON public.reservation_item USING btree (line_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_reservation_item_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_reservation_item_location_id" ON public.reservation_item USING btree (location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_claim_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_return_claim_id" ON public.return USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_return_display_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_return_display_id" ON public.return USING btree (display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_exchange_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_return_exchange_id" ON public.return USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_return_id_-31ea43a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_return_id_-31ea43a" ON public.return_fulfillment USING btree (return_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_item_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_return_item_deleted_at" ON public.return_item USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_item_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_return_item_item_id" ON public.return_item USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_item_reason_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_return_item_reason_id" ON public.return_item USING btree (reason_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_item_return_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_return_item_return_id" ON public.return_item USING btree (return_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_return_order_id" ON public.return USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_reason_parent_return_reason_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_return_reason_parent_return_reason_id" ON public.return_reason USING btree (parent_return_reason_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_reason_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_return_reason_value" ON public.return_reason USING btree (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_review_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_review_deleted_at" ON public.review USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_sales_channel_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_sales_channel_deleted_at" ON public.sales_channel USING btree (deleted_at);


--
-- Name: IDX_sales_channel_id_-1d67bae40; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_sales_channel_id_-1d67bae40" ON public.publishable_api_key_sales_channel USING btree (sales_channel_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_sales_channel_id_20b454295; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_sales_channel_id_20b454295" ON public.product_sales_channel USING btree (sales_channel_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_sales_channel_id_26d06f470; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_sales_channel_id_26d06f470" ON public.sales_channel_stock_location USING btree (sales_channel_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_service_zone_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_service_zone_deleted_at" ON public.service_zone USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_service_zone_fulfillment_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_service_zone_fulfillment_set_id" ON public.service_zone USING btree (fulfillment_set_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_service_zone_name_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_service_zone_name_unique" ON public.service_zone USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_method_adjustment_promotion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_method_adjustment_promotion_id" ON public.cart_shipping_method_adjustment USING btree (promotion_id) WHERE ((deleted_at IS NULL) AND (promotion_id IS NOT NULL));


--
-- Name: IDX_shipping_method_option_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_method_option_id" ON public.cart_shipping_method USING btree (shipping_option_id) WHERE ((deleted_at IS NULL) AND (shipping_option_id IS NOT NULL));


--
-- Name: IDX_shipping_method_tax_line_tax_rate_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_method_tax_line_tax_rate_id" ON public.cart_shipping_method_tax_line USING btree (tax_rate_id) WHERE ((deleted_at IS NULL) AND (tax_rate_id IS NOT NULL));


--
-- Name: IDX_shipping_option_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_option_deleted_at" ON public.shipping_option USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_shipping_option_id_227c36b1c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_option_id_227c36b1c" ON public.delivery_delivery_company_fulfillment_shipping_option USING btree (shipping_option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_id_ba32fa9c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_option_id_ba32fa9c" ON public.shipping_option_price_set USING btree (shipping_option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_provider_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_option_provider_id" ON public.shipping_option USING btree (provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_rule_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_option_rule_deleted_at" ON public.shipping_option_rule USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_shipping_option_rule_shipping_option_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_option_rule_shipping_option_id" ON public.shipping_option_rule USING btree (shipping_option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_service_zone_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_option_service_zone_id" ON public.shipping_option USING btree (service_zone_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_shipping_option_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_option_shipping_option_type_id" ON public.shipping_option USING btree (shipping_option_type_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_shipping_profile_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_option_shipping_profile_id" ON public.shipping_option USING btree (shipping_profile_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_type_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_option_type_deleted_at" ON public.shipping_option_type USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_shipping_profile_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_profile_deleted_at" ON public.shipping_profile USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_shipping_profile_id_17a262437; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_shipping_profile_id_17a262437" ON public.product_shipping_profile USING btree (shipping_profile_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_profile_name_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_shipping_profile_name_unique" ON public.shipping_profile USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_short_video_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_short_video_deleted_at" ON public.short_video USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_short_video_feed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_short_video_feed" ON public.short_video USING btree (status, created_at DESC) WHERE (deleted_at IS NULL);


--
-- Name: IDX_short_video_vendor_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_short_video_vendor_status" ON public.short_video USING btree (vendor_id, status) WHERE (deleted_at IS NULL);


--
-- Name: IDX_single_default_region; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_single_default_region" ON public.tax_rate USING btree (tax_region_id) WHERE ((is_default = true) AND (deleted_at IS NULL));


--
-- Name: IDX_stock_location_address_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_stock_location_address_deleted_at" ON public.stock_location_address USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_stock_location_address_id_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_stock_location_address_id_unique" ON public.stock_location USING btree (address_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_stock_location_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_stock_location_deleted_at" ON public.stock_location USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_stock_location_id_-1e5992737; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_stock_location_id_-1e5992737" ON public.location_fulfillment_provider USING btree (stock_location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_stock_location_id_-e88adb96; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_stock_location_id_-e88adb96" ON public.location_fulfillment_set USING btree (stock_location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_stock_location_id_155848331; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_stock_location_id_155848331" ON public.marketplace_vendor_stock_location_stock_location USING btree (stock_location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_stock_location_id_26d06f470; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_stock_location_id_26d06f470" ON public.sales_channel_stock_location USING btree (stock_location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_store_currency_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_store_currency_deleted_at" ON public.store_currency USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_store_currency_store_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_store_currency_store_id" ON public.store_currency USING btree (store_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_store_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_store_deleted_at" ON public.store USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_store_locale_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_store_locale_deleted_at" ON public.store_locale USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_store_locale_store_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_store_locale_store_id" ON public.store_locale USING btree (store_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tag_value_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_tag_value_unique" ON public.product_tag USING btree (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_provider_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tax_provider_deleted_at" ON public.tax_provider USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_rate_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tax_rate_deleted_at" ON public.tax_rate USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_tax_rate_rule_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tax_rate_rule_deleted_at" ON public.tax_rate_rule USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_tax_rate_rule_reference_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tax_rate_rule_reference_id" ON public.tax_rate_rule USING btree (reference_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_rate_rule_tax_rate_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tax_rate_rule_tax_rate_id" ON public.tax_rate_rule USING btree (tax_rate_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_rate_rule_unique_rate_reference; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_tax_rate_rule_unique_rate_reference" ON public.tax_rate_rule USING btree (tax_rate_id, reference_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_rate_tax_region_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tax_rate_tax_region_id" ON public.tax_rate USING btree (tax_region_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_region_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tax_region_deleted_at" ON public.tax_region USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_tax_region_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tax_region_parent_id" ON public.tax_region USING btree (parent_id);


--
-- Name: IDX_tax_region_provider_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_tax_region_provider_id" ON public.tax_region USING btree (provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_region_unique_country_nullable_province; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_tax_region_unique_country_nullable_province" ON public.tax_region USING btree (country_code) WHERE ((province_code IS NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_tax_region_unique_country_province; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_tax_region_unique_country_province" ON public.tax_region USING btree (country_code, province_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_translation_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_translation_deleted_at" ON public.translation USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_translation_locale_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_translation_locale_code" ON public.translation USING btree (locale_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_translation_reference_id_locale_code_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_translation_reference_id_locale_code_unique" ON public.translation USING btree (reference_id, locale_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_translation_reference_id_reference; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_translation_reference_id_reference" ON public.translation USING btree (reference_id, reference) WHERE (deleted_at IS NULL);


--
-- Name: IDX_translation_reference_id_reference_locale_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_translation_reference_id_reference_locale_code" ON public.translation USING btree (reference_id, reference, locale_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_translation_reference_locale_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_translation_reference_locale_code" ON public.translation USING btree (reference, locale_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_translation_settings_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_translation_settings_deleted_at" ON public.translation_settings USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_translation_settings_entity_type_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_translation_settings_entity_type_unique" ON public.translation_settings USING btree (entity_type) WHERE (deleted_at IS NULL);


--
-- Name: IDX_type_value_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_type_value_unique" ON public.product_type USING btree (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_unique_promotion_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_unique_promotion_code" ON public.promotion USING btree (code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_user_activity_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_user_activity_customer_id" ON public.user_activity USING btree (customer_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_user_activity_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_user_activity_deleted_at" ON public.user_activity USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_user_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_user_deleted_at" ON public."user" USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_user_email_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_user_email_unique" ON public."user" USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: IDX_user_id_64ff0c4c; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_user_id_64ff0c4c" ON public.user_rbac_role USING btree (user_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_user_preference_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_user_preference_deleted_at" ON public.user_preference USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_user_preference_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_user_preference_user_id" ON public.user_preference USING btree (user_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_user_preference_user_id_key_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_user_preference_user_id_key_unique" ON public.user_preference USING btree (user_id, key) WHERE (deleted_at IS NULL);


--
-- Name: IDX_variant_id_17b4c4e35; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_variant_id_17b4c4e35" ON public.product_variant_inventory_item USING btree (variant_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_variant_id_52b23597; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_variant_id_52b23597" ON public.product_variant_price_set USING btree (variant_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_vendor_admin_email_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_vendor_admin_email_unique" ON public.vendor_admin USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: IDX_vendor_admin_vendor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_vendor_admin_vendor_id" ON public.vendor_admin USING btree (vendor_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_vendor_follow_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_vendor_follow_customer_id" ON public.vendor_follow USING btree (customer_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_vendor_follow_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_vendor_follow_deleted_at" ON public.vendor_follow USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_vendor_follow_vendor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_vendor_follow_vendor_id" ON public.vendor_follow USING btree (vendor_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_vendor_handle_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_vendor_handle_unique" ON public.vendor USING btree (handle) WHERE (deleted_at IS NULL);


--
-- Name: IDX_vendor_id_-12e0822f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_vendor_id_-12e0822f" ON public.marketplace_vendor_order_order USING btree (vendor_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_vendor_id_-d14c9099; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_vendor_id_-d14c9099" ON public.marketplace_vendor_promotion_promotion USING btree (vendor_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_vendor_id_155848331; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_vendor_id_155848331" ON public.marketplace_vendor_stock_location_stock_location USING btree (vendor_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_vendor_id_3ca1b85b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_vendor_id_3ca1b85b" ON public.marketplace_vendor_product_product USING btree (vendor_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_vendor_payout_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_vendor_payout_deleted_at" ON public.vendor_payout USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_vendor_payout_vendor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_vendor_payout_vendor_id" ON public.vendor_payout USING btree (vendor_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_video_comment_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_video_comment_deleted_at" ON public.video_comment USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_video_comment_video; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_video_comment_video" ON public.video_comment USING btree (video_id, created_at DESC) WHERE (deleted_at IS NULL);


--
-- Name: IDX_video_like_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_video_like_deleted_at" ON public.video_like USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_video_like_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_video_like_unique" ON public.video_like USING btree (video_id, customer_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_video_save_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_video_save_deleted_at" ON public.video_save USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_video_save_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_video_save_unique" ON public.video_save USING btree (video_id, customer_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_view_configuration_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_view_configuration_deleted_at" ON public.view_configuration USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_view_configuration_entity_is_system_default; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_view_configuration_entity_is_system_default" ON public.view_configuration USING btree (entity, is_system_default) WHERE (deleted_at IS NULL);


--
-- Name: IDX_view_configuration_entity_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_view_configuration_entity_user_id" ON public.view_configuration USING btree (entity, user_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_view_configuration_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_view_configuration_user_id" ON public.view_configuration USING btree (user_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_wheel_prize_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_wheel_prize_deleted_at" ON public.wheel_prize USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_wheel_spin_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_wheel_spin_deleted_at" ON public.wheel_spin USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_wheel_spin_loyalty_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_wheel_spin_loyalty_id" ON public.wheel_spin USING btree (loyalty_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_workflow_execution_deleted_at" ON public.workflow_execution USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_workflow_execution_id" ON public.workflow_execution USING btree (id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_retention_time_updated_at_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_workflow_execution_retention_time_updated_at_state" ON public.workflow_execution USING btree (retention_time, updated_at, state) WHERE ((deleted_at IS NULL) AND (retention_time IS NOT NULL));


--
-- Name: IDX_workflow_execution_run_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_workflow_execution_run_id" ON public.workflow_execution USING btree (run_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_workflow_execution_state" ON public.workflow_execution USING btree (state) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_state_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_workflow_execution_state_updated_at" ON public.workflow_execution USING btree (state, updated_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_transaction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_workflow_execution_transaction_id" ON public.workflow_execution USING btree (transaction_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_updated_at_retention_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_workflow_execution_updated_at_retention_time" ON public.workflow_execution USING btree (updated_at, retention_time) WHERE ((deleted_at IS NULL) AND (retention_time IS NOT NULL) AND ((state)::text = ANY ((ARRAY['done'::character varying, 'failed'::character varying, 'reverted'::character varying])::text[])));


--
-- Name: IDX_workflow_execution_workflow_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_workflow_execution_workflow_id" ON public.workflow_execution USING btree (workflow_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_workflow_id_transaction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IDX_workflow_execution_workflow_id_transaction_id" ON public.workflow_execution USING btree (workflow_id, transaction_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_workflow_id_transaction_id_run_id_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IDX_workflow_execution_workflow_id_transaction_id_run_id_unique" ON public.workflow_execution USING btree (workflow_id, transaction_id, run_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_script_name_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_script_name_unique ON public.script_migrations USING btree (script_name);


--
-- Name: tax_rate_rule FK_tax_rate_rule_tax_rate_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_rate_rule
    ADD CONSTRAINT "FK_tax_rate_rule_tax_rate_id" FOREIGN KEY (tax_rate_id) REFERENCES public.tax_rate(id) ON DELETE CASCADE;


--
-- Name: tax_rate FK_tax_rate_tax_region_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_rate
    ADD CONSTRAINT "FK_tax_rate_tax_region_id" FOREIGN KEY (tax_region_id) REFERENCES public.tax_region(id) ON DELETE CASCADE;


--
-- Name: tax_region FK_tax_region_parent_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_region
    ADD CONSTRAINT "FK_tax_region_parent_id" FOREIGN KEY (parent_id) REFERENCES public.tax_region(id) ON DELETE CASCADE;


--
-- Name: tax_region FK_tax_region_provider_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_region
    ADD CONSTRAINT "FK_tax_region_provider_id" FOREIGN KEY (provider_id) REFERENCES public.tax_provider(id) ON DELETE SET NULL;


--
-- Name: application_method_buy_rules application_method_buy_rules_application_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_method_buy_rules
    ADD CONSTRAINT application_method_buy_rules_application_method_id_foreign FOREIGN KEY (application_method_id) REFERENCES public.promotion_application_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: application_method_buy_rules application_method_buy_rules_promotion_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_method_buy_rules
    ADD CONSTRAINT application_method_buy_rules_promotion_rule_id_foreign FOREIGN KEY (promotion_rule_id) REFERENCES public.promotion_rule(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: application_method_target_rules application_method_target_rules_application_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_method_target_rules
    ADD CONSTRAINT application_method_target_rules_application_method_id_foreign FOREIGN KEY (application_method_id) REFERENCES public.promotion_application_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: application_method_target_rules application_method_target_rules_promotion_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_method_target_rules
    ADD CONSTRAINT application_method_target_rules_promotion_rule_id_foreign FOREIGN KEY (promotion_rule_id) REFERENCES public.promotion_rule(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: capture capture_payment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.capture
    ADD CONSTRAINT capture_payment_id_foreign FOREIGN KEY (payment_id) REFERENCES public.payment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart cart_billing_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_billing_address_id_foreign FOREIGN KEY (billing_address_id) REFERENCES public.cart_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: cart_line_item_adjustment cart_line_item_adjustment_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_line_item_adjustment
    ADD CONSTRAINT cart_line_item_adjustment_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.cart_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_line_item cart_line_item_cart_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_line_item
    ADD CONSTRAINT cart_line_item_cart_id_foreign FOREIGN KEY (cart_id) REFERENCES public.cart(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_line_item_tax_line cart_line_item_tax_line_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_line_item_tax_line
    ADD CONSTRAINT cart_line_item_tax_line_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.cart_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart cart_shipping_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_shipping_address_id_foreign FOREIGN KEY (shipping_address_id) REFERENCES public.cart_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: cart_shipping_method_adjustment cart_shipping_method_adjustment_shipping_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_shipping_method_adjustment
    ADD CONSTRAINT cart_shipping_method_adjustment_shipping_method_id_foreign FOREIGN KEY (shipping_method_id) REFERENCES public.cart_shipping_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_shipping_method cart_shipping_method_cart_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_shipping_method
    ADD CONSTRAINT cart_shipping_method_cart_id_foreign FOREIGN KEY (cart_id) REFERENCES public.cart(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_shipping_method_tax_line cart_shipping_method_tax_line_shipping_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_shipping_method_tax_line
    ADD CONSTRAINT cart_shipping_method_tax_line_shipping_method_id_foreign FOREIGN KEY (shipping_method_id) REFERENCES public.cart_shipping_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: credit_line credit_line_cart_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_line
    ADD CONSTRAINT credit_line_cart_id_foreign FOREIGN KEY (cart_id) REFERENCES public.cart(id) ON UPDATE CASCADE;


--
-- Name: customer_address customer_address_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_address
    ADD CONSTRAINT customer_address_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customer(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customer_group_customer customer_group_customer_customer_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_group_customer
    ADD CONSTRAINT customer_group_customer_customer_group_id_foreign FOREIGN KEY (customer_group_id) REFERENCES public.customer_group(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customer_group_customer customer_group_customer_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_group_customer
    ADD CONSTRAINT customer_group_customer_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customer(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: daily_check_in daily_check_in_loyalty_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_check_in
    ADD CONSTRAINT daily_check_in_loyalty_id_foreign FOREIGN KEY (loyalty_id) REFERENCES public.customer_loyalty(id) ON UPDATE CASCADE;


--
-- Name: delivery_driver delivery_driver_delivery_company_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_driver
    ADD CONSTRAINT delivery_driver_delivery_company_id_foreign FOREIGN KEY (delivery_company_id) REFERENCES public.delivery_company(id) ON UPDATE CASCADE;


--
-- Name: fulfillment fulfillment_delivery_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT fulfillment_delivery_address_id_foreign FOREIGN KEY (delivery_address_id) REFERENCES public.fulfillment_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: fulfillment_item fulfillment_item_fulfillment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillment_item
    ADD CONSTRAINT fulfillment_item_fulfillment_id_foreign FOREIGN KEY (fulfillment_id) REFERENCES public.fulfillment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fulfillment_label fulfillment_label_fulfillment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillment_label
    ADD CONSTRAINT fulfillment_label_fulfillment_id_foreign FOREIGN KEY (fulfillment_id) REFERENCES public.fulfillment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fulfillment fulfillment_provider_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT fulfillment_provider_id_foreign FOREIGN KEY (provider_id) REFERENCES public.fulfillment_provider(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: fulfillment fulfillment_shipping_option_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT fulfillment_shipping_option_id_foreign FOREIGN KEY (shipping_option_id) REFERENCES public.shipping_option(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: geo_zone geo_zone_service_zone_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.geo_zone
    ADD CONSTRAINT geo_zone_service_zone_id_foreign FOREIGN KEY (service_zone_id) REFERENCES public.service_zone(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: image image_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: inventory_level inventory_level_inventory_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_level
    ADD CONSTRAINT inventory_level_inventory_item_id_foreign FOREIGN KEY (inventory_item_id) REFERENCES public.inventory_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: message message_conversation_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message
    ADD CONSTRAINT message_conversation_id_foreign FOREIGN KEY (conversation_id) REFERENCES public.conversation(id) ON UPDATE CASCADE;


--
-- Name: notification notification_provider_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_provider_id_foreign FOREIGN KEY (provider_id) REFERENCES public.notification_provider(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: order order_billing_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_billing_address_id_foreign FOREIGN KEY (billing_address_id) REFERENCES public.order_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: order_change_action order_change_action_order_change_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_change_action
    ADD CONSTRAINT order_change_action_order_change_id_foreign FOREIGN KEY (order_change_id) REFERENCES public.order_change(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_change order_change_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_change
    ADD CONSTRAINT order_change_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_credit_line order_credit_line_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_credit_line
    ADD CONSTRAINT order_credit_line_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_item order_item_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.order_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_item order_item_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_line_item_adjustment order_line_item_adjustment_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_line_item_adjustment
    ADD CONSTRAINT order_line_item_adjustment_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.order_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_line_item_tax_line order_line_item_tax_line_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_line_item_tax_line
    ADD CONSTRAINT order_line_item_tax_line_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.order_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_line_item order_line_item_totals_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_line_item
    ADD CONSTRAINT order_line_item_totals_id_foreign FOREIGN KEY (totals_id) REFERENCES public.order_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order order_shipping_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_shipping_address_id_foreign FOREIGN KEY (shipping_address_id) REFERENCES public.order_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: order_shipping_method_adjustment order_shipping_method_adjustment_shipping_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_shipping_method_adjustment
    ADD CONSTRAINT order_shipping_method_adjustment_shipping_method_id_foreign FOREIGN KEY (shipping_method_id) REFERENCES public.order_shipping_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_shipping_method_tax_line order_shipping_method_tax_line_shipping_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_shipping_method_tax_line
    ADD CONSTRAINT order_shipping_method_tax_line_shipping_method_id_foreign FOREIGN KEY (shipping_method_id) REFERENCES public.order_shipping_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_shipping order_shipping_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_shipping
    ADD CONSTRAINT order_shipping_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_summary order_summary_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_summary
    ADD CONSTRAINT order_summary_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_transaction order_transaction_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_transaction
    ADD CONSTRAINT order_transaction_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment_collection_payment_providers payment_collection_payment_providers_payment_col_aa276_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_collection_payment_providers
    ADD CONSTRAINT payment_collection_payment_providers_payment_col_aa276_foreign FOREIGN KEY (payment_collection_id) REFERENCES public.payment_collection(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment_collection_payment_providers payment_collection_payment_providers_payment_pro_2d555_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_collection_payment_providers
    ADD CONSTRAINT payment_collection_payment_providers_payment_pro_2d555_foreign FOREIGN KEY (payment_provider_id) REFERENCES public.payment_provider(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment payment_payment_collection_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_payment_collection_id_foreign FOREIGN KEY (payment_collection_id) REFERENCES public.payment_collection(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment_session payment_session_payment_collection_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_session
    ADD CONSTRAINT payment_session_payment_collection_id_foreign FOREIGN KEY (payment_collection_id) REFERENCES public.payment_collection(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: price_list_rule price_list_rule_price_list_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.price_list_rule
    ADD CONSTRAINT price_list_rule_price_list_id_foreign FOREIGN KEY (price_list_id) REFERENCES public.price_list(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: price price_price_list_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT price_price_list_id_foreign FOREIGN KEY (price_list_id) REFERENCES public.price_list(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: price price_price_set_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT price_price_set_id_foreign FOREIGN KEY (price_set_id) REFERENCES public.price_set(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: price_rule price_rule_price_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.price_rule
    ADD CONSTRAINT price_rule_price_id_foreign FOREIGN KEY (price_id) REFERENCES public.price(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_category product_category_parent_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_category
    ADD CONSTRAINT product_category_parent_category_id_foreign FOREIGN KEY (parent_category_id) REFERENCES public.product_category(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_category_product product_category_product_product_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_category_product
    ADD CONSTRAINT product_category_product_product_category_id_foreign FOREIGN KEY (product_category_id) REFERENCES public.product_category(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_category_product product_category_product_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_category_product
    ADD CONSTRAINT product_category_product_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product product_collection_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_collection_id_foreign FOREIGN KEY (collection_id) REFERENCES public.product_collection(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: product_option product_option_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_option
    ADD CONSTRAINT product_option_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_option_value product_option_value_option_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_option_value
    ADD CONSTRAINT product_option_value_option_id_foreign FOREIGN KEY (option_id) REFERENCES public.product_option(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_tags product_tags_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_tags
    ADD CONSTRAINT product_tags_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_tags product_tags_product_tag_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_tags
    ADD CONSTRAINT product_tags_product_tag_id_foreign FOREIGN KEY (product_tag_id) REFERENCES public.product_tag(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product product_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_type_id_foreign FOREIGN KEY (type_id) REFERENCES public.product_type(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: product_variant_option product_variant_option_option_value_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variant_option
    ADD CONSTRAINT product_variant_option_option_value_id_foreign FOREIGN KEY (option_value_id) REFERENCES public.product_option_value(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_variant_option product_variant_option_variant_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variant_option
    ADD CONSTRAINT product_variant_option_variant_id_foreign FOREIGN KEY (variant_id) REFERENCES public.product_variant(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_variant product_variant_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variant
    ADD CONSTRAINT product_variant_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_variant_product_image product_variant_product_image_image_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variant_product_image
    ADD CONSTRAINT product_variant_product_image_image_id_foreign FOREIGN KEY (image_id) REFERENCES public.image(id) ON DELETE CASCADE;


--
-- Name: promotion_application_method promotion_application_method_promotion_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_application_method
    ADD CONSTRAINT promotion_application_method_promotion_id_foreign FOREIGN KEY (promotion_id) REFERENCES public.promotion(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion_campaign_budget promotion_campaign_budget_campaign_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_campaign_budget
    ADD CONSTRAINT promotion_campaign_budget_campaign_id_foreign FOREIGN KEY (campaign_id) REFERENCES public.promotion_campaign(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion_campaign_budget_usage promotion_campaign_budget_usage_budget_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_campaign_budget_usage
    ADD CONSTRAINT promotion_campaign_budget_usage_budget_id_foreign FOREIGN KEY (budget_id) REFERENCES public.promotion_campaign_budget(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion promotion_campaign_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_campaign_id_foreign FOREIGN KEY (campaign_id) REFERENCES public.promotion_campaign(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: promotion_promotion_rule promotion_promotion_rule_promotion_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_promotion_rule
    ADD CONSTRAINT promotion_promotion_rule_promotion_id_foreign FOREIGN KEY (promotion_id) REFERENCES public.promotion(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion_promotion_rule promotion_promotion_rule_promotion_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_promotion_rule
    ADD CONSTRAINT promotion_promotion_rule_promotion_rule_id_foreign FOREIGN KEY (promotion_rule_id) REFERENCES public.promotion_rule(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion_rule_value promotion_rule_value_promotion_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promotion_rule_value
    ADD CONSTRAINT promotion_rule_value_promotion_rule_id_foreign FOREIGN KEY (promotion_rule_id) REFERENCES public.promotion_rule(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: provider_identity provider_identity_auth_identity_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.provider_identity
    ADD CONSTRAINT provider_identity_auth_identity_id_foreign FOREIGN KEY (auth_identity_id) REFERENCES public.auth_identity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: refund refund_payment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund
    ADD CONSTRAINT refund_payment_id_foreign FOREIGN KEY (payment_id) REFERENCES public.payment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: region_country region_country_region_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.region_country
    ADD CONSTRAINT region_country_region_id_foreign FOREIGN KEY (region_id) REFERENCES public.region(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: reservation_item reservation_item_inventory_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reservation_item
    ADD CONSTRAINT reservation_item_inventory_item_id_foreign FOREIGN KEY (inventory_item_id) REFERENCES public.inventory_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: return_reason return_reason_parent_return_reason_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.return_reason
    ADD CONSTRAINT return_reason_parent_return_reason_id_foreign FOREIGN KEY (parent_return_reason_id) REFERENCES public.return_reason(id);


--
-- Name: service_zone service_zone_fulfillment_set_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_zone
    ADD CONSTRAINT service_zone_fulfillment_set_id_foreign FOREIGN KEY (fulfillment_set_id) REFERENCES public.fulfillment_set(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shipping_option shipping_option_provider_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_provider_id_foreign FOREIGN KEY (provider_id) REFERENCES public.fulfillment_provider(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: shipping_option_rule shipping_option_rule_shipping_option_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_option_rule
    ADD CONSTRAINT shipping_option_rule_shipping_option_id_foreign FOREIGN KEY (shipping_option_id) REFERENCES public.shipping_option(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shipping_option shipping_option_service_zone_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_service_zone_id_foreign FOREIGN KEY (service_zone_id) REFERENCES public.service_zone(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shipping_option shipping_option_shipping_option_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_shipping_option_type_id_foreign FOREIGN KEY (shipping_option_type_id) REFERENCES public.shipping_option_type(id) ON UPDATE CASCADE;


--
-- Name: shipping_option shipping_option_shipping_profile_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_shipping_profile_id_foreign FOREIGN KEY (shipping_profile_id) REFERENCES public.shipping_profile(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: stock_location stock_location_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_location
    ADD CONSTRAINT stock_location_address_id_foreign FOREIGN KEY (address_id) REFERENCES public.stock_location_address(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: store_currency store_currency_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.store_currency
    ADD CONSTRAINT store_currency_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.store(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: store_locale store_locale_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.store_locale
    ADD CONSTRAINT store_locale_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.store(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: vendor_admin vendor_admin_vendor_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_admin
    ADD CONSTRAINT vendor_admin_vendor_id_foreign FOREIGN KEY (vendor_id) REFERENCES public.vendor(id) ON UPDATE CASCADE;


--
-- Name: vendor_payout vendor_payout_vendor_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendor_payout
    ADD CONSTRAINT vendor_payout_vendor_id_foreign FOREIGN KEY (vendor_id) REFERENCES public.vendor(id) ON UPDATE CASCADE;


--
-- Name: wheel_spin wheel_spin_loyalty_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wheel_spin
    ADD CONSTRAINT wheel_spin_loyalty_id_foreign FOREIGN KEY (loyalty_id) REFERENCES public.customer_loyalty(id) ON UPDATE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict 8BhKdivFFnKdFB6MX3QTYs9A1zUVeopx4c8fSWV73rVTBsuScwHTdceNWV8U1pm

