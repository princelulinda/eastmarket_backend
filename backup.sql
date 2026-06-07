--
-- PostgreSQL database dump
--

\restrict 4SZiYWRVf0lyicvsELKP5YBanxBHv8ipobwyzzZdSuVNk2hqh2kKBeDvnQbeLzU

-- Dumped from database version 18.3 (Ubuntu 18.3-1)
-- Dumped by pg_dump version 18.3 (Ubuntu 18.3-1)

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
-- Name: claim_reason_enum; Type: TYPE; Schema: public; Owner: princelulinda
--

CREATE TYPE public.claim_reason_enum AS ENUM (
    'missing_item',
    'wrong_item',
    'production_failure',
    'other'
);


ALTER TYPE public.claim_reason_enum OWNER TO princelulinda;

--
-- Name: order_claim_type_enum; Type: TYPE; Schema: public; Owner: princelulinda
--

CREATE TYPE public.order_claim_type_enum AS ENUM (
    'refund',
    'replace'
);


ALTER TYPE public.order_claim_type_enum OWNER TO princelulinda;

--
-- Name: order_status_enum; Type: TYPE; Schema: public; Owner: princelulinda
--

CREATE TYPE public.order_status_enum AS ENUM (
    'pending',
    'completed',
    'draft',
    'archived',
    'canceled',
    'requires_action'
);


ALTER TYPE public.order_status_enum OWNER TO princelulinda;

--
-- Name: return_status_enum; Type: TYPE; Schema: public; Owner: princelulinda
--

CREATE TYPE public.return_status_enum AS ENUM (
    'open',
    'requested',
    'received',
    'partially_received',
    'canceled'
);


ALTER TYPE public.return_status_enum OWNER TO princelulinda;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account_holder; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.account_holder OWNER TO princelulinda;

--
-- Name: analytics_event; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.analytics_event OWNER TO princelulinda;

--
-- Name: api_key; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.api_key OWNER TO princelulinda;

--
-- Name: app_notification; Type: TABLE; Schema: public; Owner: princelulinda
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
    CONSTRAINT app_notification_type_check CHECK ((type = ANY (ARRAY['new_message'::text, 'new_order'::text, 'order_status'::text, 'order_shipped'::text, 'order_delivered'::text, 'order_cancelled'::text, 'new_review'::text, 'system'::text])))
);


ALTER TABLE public.app_notification OWNER TO princelulinda;

--
-- Name: application_method_buy_rules; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.application_method_buy_rules (
    application_method_id text NOT NULL,
    promotion_rule_id text NOT NULL
);


ALTER TABLE public.application_method_buy_rules OWNER TO princelulinda;

--
-- Name: application_method_target_rules; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.application_method_target_rules (
    application_method_id text NOT NULL,
    promotion_rule_id text NOT NULL
);


ALTER TABLE public.application_method_target_rules OWNER TO princelulinda;

--
-- Name: auth_identity; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.auth_identity (
    id text NOT NULL,
    app_metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.auth_identity OWNER TO princelulinda;

--
-- Name: capture; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.capture OWNER TO princelulinda;

--
-- Name: cart; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.cart OWNER TO princelulinda;

--
-- Name: cart_address; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.cart_address OWNER TO princelulinda;

--
-- Name: cart_line_item; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.cart_line_item OWNER TO princelulinda;

--
-- Name: cart_line_item_adjustment; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.cart_line_item_adjustment OWNER TO princelulinda;

--
-- Name: cart_line_item_tax_line; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.cart_line_item_tax_line OWNER TO princelulinda;

--
-- Name: cart_payment_collection; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.cart_payment_collection (
    cart_id character varying(255) NOT NULL,
    payment_collection_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.cart_payment_collection OWNER TO princelulinda;

--
-- Name: cart_promotion; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.cart_promotion (
    cart_id character varying(255) NOT NULL,
    promotion_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.cart_promotion OWNER TO princelulinda;

--
-- Name: cart_shipping_method; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.cart_shipping_method OWNER TO princelulinda;

--
-- Name: cart_shipping_method_adjustment; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.cart_shipping_method_adjustment OWNER TO princelulinda;

--
-- Name: cart_shipping_method_tax_line; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.cart_shipping_method_tax_line OWNER TO princelulinda;

--
-- Name: conversation; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.conversation (
    id text NOT NULL,
    customer_id text,
    vendor_id text,
    last_message_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.conversation OWNER TO princelulinda;

--
-- Name: credit_line; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.credit_line OWNER TO princelulinda;

--
-- Name: currency; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.currency OWNER TO princelulinda;

--
-- Name: customer; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.customer OWNER TO princelulinda;

--
-- Name: customer_account_holder; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.customer_account_holder (
    customer_id character varying(255) NOT NULL,
    account_holder_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.customer_account_holder OWNER TO princelulinda;

--
-- Name: customer_address; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.customer_address OWNER TO princelulinda;

--
-- Name: customer_group; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.customer_group OWNER TO princelulinda;

--
-- Name: customer_group_customer; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.customer_group_customer OWNER TO princelulinda;

--
-- Name: customer_payment_method; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.customer_payment_method OWNER TO princelulinda;

--
-- Name: delivery_company; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.delivery_company OWNER TO princelulinda;

--
-- Name: delivery_delivery_company_fulfillment_shipping_option; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.delivery_delivery_company_fulfillment_shipping_option (
    delivery_company_id character varying(255) CONSTRAINT delivery_delivery_company_fulfillm_delivery_company_id_not_null NOT NULL,
    shipping_option_id character varying(255) CONSTRAINT delivery_delivery_company_fulfillme_shipping_option_id_not_null NOT NULL,
    id character varying(255) CONSTRAINT delivery_delivery_company_fulfillment_shipping_opti_id_not_null NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP CONSTRAINT delivery_delivery_company_fulfillment_shipp_created_at_not_null NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP CONSTRAINT delivery_delivery_company_fulfillment_shipp_updated_at_not_null NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.delivery_delivery_company_fulfillment_shipping_option OWNER TO princelulinda;

--
-- Name: delivery_driver; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.delivery_driver OWNER TO princelulinda;

--
-- Name: fulfillment; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.fulfillment OWNER TO princelulinda;

--
-- Name: fulfillment_address; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.fulfillment_address OWNER TO princelulinda;

--
-- Name: fulfillment_item; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.fulfillment_item OWNER TO princelulinda;

--
-- Name: fulfillment_label; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.fulfillment_label OWNER TO princelulinda;

--
-- Name: fulfillment_provider; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.fulfillment_provider (
    id text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.fulfillment_provider OWNER TO princelulinda;

--
-- Name: fulfillment_set; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.fulfillment_set OWNER TO princelulinda;

--
-- Name: geo_zone; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.geo_zone OWNER TO princelulinda;

--
-- Name: image; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.image OWNER TO princelulinda;

--
-- Name: inventory_item; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.inventory_item OWNER TO princelulinda;

--
-- Name: inventory_level; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.inventory_level OWNER TO princelulinda;

--
-- Name: invite; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.invite OWNER TO princelulinda;

--
-- Name: link_module_migrations; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.link_module_migrations (
    id integer NOT NULL,
    table_name character varying(255) NOT NULL,
    link_descriptor jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.link_module_migrations OWNER TO princelulinda;

--
-- Name: link_module_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: princelulinda
--

CREATE SEQUENCE public.link_module_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.link_module_migrations_id_seq OWNER TO princelulinda;

--
-- Name: link_module_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: princelulinda
--

ALTER SEQUENCE public.link_module_migrations_id_seq OWNED BY public.link_module_migrations.id;


--
-- Name: locale; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.locale (
    id text NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.locale OWNER TO princelulinda;

--
-- Name: location_fulfillment_provider; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.location_fulfillment_provider (
    stock_location_id character varying(255) NOT NULL,
    fulfillment_provider_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.location_fulfillment_provider OWNER TO princelulinda;

--
-- Name: location_fulfillment_set; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.location_fulfillment_set (
    stock_location_id character varying(255) NOT NULL,
    fulfillment_set_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.location_fulfillment_set OWNER TO princelulinda;

--
-- Name: marketplace_vendor_order_order; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.marketplace_vendor_order_order (
    vendor_id character varying(255) NOT NULL,
    order_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.marketplace_vendor_order_order OWNER TO princelulinda;

--
-- Name: marketplace_vendor_product_product; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.marketplace_vendor_product_product (
    vendor_id character varying(255) NOT NULL,
    product_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.marketplace_vendor_product_product OWNER TO princelulinda;

--
-- Name: marketplace_vendor_promotion_promotion; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.marketplace_vendor_promotion_promotion (
    vendor_id character varying(255) NOT NULL,
    promotion_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.marketplace_vendor_promotion_promotion OWNER TO princelulinda;

--
-- Name: marketplace_vendor_stock_location_stock_location; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.marketplace_vendor_stock_location_stock_location (
    vendor_id character varying(255) CONSTRAINT marketplace_vendor_stock_location_stock_loca_vendor_id_not_null NOT NULL,
    stock_location_id character varying(255) CONSTRAINT marketplace_vendor_stock_location_st_stock_location_id_not_null NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP CONSTRAINT marketplace_vendor_stock_location_stock_loc_created_at_not_null NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP CONSTRAINT marketplace_vendor_stock_location_stock_loc_updated_at_not_null NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.marketplace_vendor_stock_location_stock_location OWNER TO princelulinda;

--
-- Name: message; Type: TABLE; Schema: public; Owner: princelulinda
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
    CONSTRAINT message_sender_type_check CHECK ((sender_type = ANY (ARRAY['customer'::text, 'vendor'::text]))),
    CONSTRAINT message_type_check CHECK ((type = ANY (ARRAY['text'::text, 'image'::text, 'file'::text])))
);


ALTER TABLE public.message OWNER TO princelulinda;

--
-- Name: mikro_orm_migrations; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.mikro_orm_migrations (
    id integer NOT NULL,
    name character varying(255),
    executed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.mikro_orm_migrations OWNER TO princelulinda;

--
-- Name: mikro_orm_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: princelulinda
--

CREATE SEQUENCE public.mikro_orm_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mikro_orm_migrations_id_seq OWNER TO princelulinda;

--
-- Name: mikro_orm_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: princelulinda
--

ALTER SEQUENCE public.mikro_orm_migrations_id_seq OWNED BY public.mikro_orm_migrations.id;


--
-- Name: notification; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.notification OWNER TO princelulinda;

--
-- Name: notification_provider; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.notification_provider OWNER TO princelulinda;

--
-- Name: order; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public."order" OWNER TO princelulinda;

--
-- Name: order_address; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.order_address OWNER TO princelulinda;

--
-- Name: order_cart; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.order_cart (
    order_id character varying(255) NOT NULL,
    cart_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_cart OWNER TO princelulinda;

--
-- Name: order_change; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.order_change OWNER TO princelulinda;

--
-- Name: order_change_action; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.order_change_action OWNER TO princelulinda;

--
-- Name: order_change_action_ordering_seq; Type: SEQUENCE; Schema: public; Owner: princelulinda
--

CREATE SEQUENCE public.order_change_action_ordering_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_change_action_ordering_seq OWNER TO princelulinda;

--
-- Name: order_change_action_ordering_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: princelulinda
--

ALTER SEQUENCE public.order_change_action_ordering_seq OWNED BY public.order_change_action.ordering;


--
-- Name: order_claim; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.order_claim OWNER TO princelulinda;

--
-- Name: order_claim_display_id_seq; Type: SEQUENCE; Schema: public; Owner: princelulinda
--

CREATE SEQUENCE public.order_claim_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_claim_display_id_seq OWNER TO princelulinda;

--
-- Name: order_claim_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: princelulinda
--

ALTER SEQUENCE public.order_claim_display_id_seq OWNED BY public.order_claim.display_id;


--
-- Name: order_claim_item; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.order_claim_item OWNER TO princelulinda;

--
-- Name: order_claim_item_image; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.order_claim_item_image OWNER TO princelulinda;

--
-- Name: order_credit_line; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.order_credit_line OWNER TO princelulinda;

--
-- Name: order_display_id_seq; Type: SEQUENCE; Schema: public; Owner: princelulinda
--

CREATE SEQUENCE public.order_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_display_id_seq OWNER TO princelulinda;

--
-- Name: order_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: princelulinda
--

ALTER SEQUENCE public.order_display_id_seq OWNED BY public."order".display_id;


--
-- Name: order_exchange; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.order_exchange OWNER TO princelulinda;

--
-- Name: order_exchange_display_id_seq; Type: SEQUENCE; Schema: public; Owner: princelulinda
--

CREATE SEQUENCE public.order_exchange_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_exchange_display_id_seq OWNER TO princelulinda;

--
-- Name: order_exchange_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: princelulinda
--

ALTER SEQUENCE public.order_exchange_display_id_seq OWNED BY public.order_exchange.display_id;


--
-- Name: order_exchange_item; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.order_exchange_item OWNER TO princelulinda;

--
-- Name: order_fulfillment; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.order_fulfillment (
    order_id character varying(255) NOT NULL,
    fulfillment_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_fulfillment OWNER TO princelulinda;

--
-- Name: order_item; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.order_item OWNER TO princelulinda;

--
-- Name: order_line_item; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.order_line_item OWNER TO princelulinda;

--
-- Name: order_line_item_adjustment; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.order_line_item_adjustment OWNER TO princelulinda;

--
-- Name: order_line_item_tax_line; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.order_line_item_tax_line OWNER TO princelulinda;

--
-- Name: order_payment_collection; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.order_payment_collection (
    order_id character varying(255) NOT NULL,
    payment_collection_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_payment_collection OWNER TO princelulinda;

--
-- Name: order_promotion; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.order_promotion (
    order_id character varying(255) NOT NULL,
    promotion_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_promotion OWNER TO princelulinda;

--
-- Name: order_shipping; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.order_shipping OWNER TO princelulinda;

--
-- Name: order_shipping_method; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.order_shipping_method OWNER TO princelulinda;

--
-- Name: order_shipping_method_adjustment; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.order_shipping_method_adjustment OWNER TO princelulinda;

--
-- Name: order_shipping_method_tax_line; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.order_shipping_method_tax_line OWNER TO princelulinda;

--
-- Name: order_summary; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.order_summary OWNER TO princelulinda;

--
-- Name: order_transaction; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.order_transaction OWNER TO princelulinda;

--
-- Name: payment; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.payment OWNER TO princelulinda;

--
-- Name: payment_collection; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.payment_collection OWNER TO princelulinda;

--
-- Name: payment_collection_payment_providers; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.payment_collection_payment_providers (
    payment_collection_id text CONSTRAINT payment_collection_payment_provi_payment_collection_id_not_null NOT NULL,
    payment_provider_id text CONSTRAINT payment_collection_payment_provide_payment_provider_id_not_null NOT NULL
);


ALTER TABLE public.payment_collection_payment_providers OWNER TO princelulinda;

--
-- Name: payment_provider; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.payment_provider (
    id text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.payment_provider OWNER TO princelulinda;

--
-- Name: payment_session; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.payment_session OWNER TO princelulinda;

--
-- Name: price; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.price OWNER TO princelulinda;

--
-- Name: price_list; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.price_list OWNER TO princelulinda;

--
-- Name: price_list_rule; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.price_list_rule OWNER TO princelulinda;

--
-- Name: price_preference; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.price_preference OWNER TO princelulinda;

--
-- Name: price_rule; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.price_rule OWNER TO princelulinda;

--
-- Name: price_set; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.price_set (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.price_set OWNER TO princelulinda;

--
-- Name: product; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.product OWNER TO princelulinda;

--
-- Name: product_category; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.product_category OWNER TO princelulinda;

--
-- Name: product_category_product; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.product_category_product (
    product_id text NOT NULL,
    product_category_id text NOT NULL
);


ALTER TABLE public.product_category_product OWNER TO princelulinda;

--
-- Name: product_collection; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.product_collection OWNER TO princelulinda;

--
-- Name: product_option; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.product_option OWNER TO princelulinda;

--
-- Name: product_option_value; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.product_option_value OWNER TO princelulinda;

--
-- Name: product_sales_channel; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.product_sales_channel (
    product_id character varying(255) NOT NULL,
    sales_channel_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_sales_channel OWNER TO princelulinda;

--
-- Name: product_shipping_profile; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.product_shipping_profile (
    product_id character varying(255) NOT NULL,
    shipping_profile_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_shipping_profile OWNER TO princelulinda;

--
-- Name: product_tag; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.product_tag (
    id text NOT NULL,
    value text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_tag OWNER TO princelulinda;

--
-- Name: product_tags; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.product_tags (
    product_id text NOT NULL,
    product_tag_id text NOT NULL
);


ALTER TABLE public.product_tags OWNER TO princelulinda;

--
-- Name: product_type; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.product_type (
    id text NOT NULL,
    value text NOT NULL,
    metadata json,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_type OWNER TO princelulinda;

--
-- Name: product_variant; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.product_variant OWNER TO princelulinda;

--
-- Name: product_variant_inventory_item; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.product_variant_inventory_item OWNER TO princelulinda;

--
-- Name: product_variant_option; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.product_variant_option (
    variant_id text NOT NULL,
    option_value_id text NOT NULL
);


ALTER TABLE public.product_variant_option OWNER TO princelulinda;

--
-- Name: product_variant_price_set; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.product_variant_price_set (
    variant_id character varying(255) NOT NULL,
    price_set_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_variant_price_set OWNER TO princelulinda;

--
-- Name: product_variant_product_image; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.product_variant_product_image (
    id text NOT NULL,
    variant_id text NOT NULL,
    image_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_variant_product_image OWNER TO princelulinda;

--
-- Name: promotion; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.promotion OWNER TO princelulinda;

--
-- Name: promotion_application_method; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.promotion_application_method OWNER TO princelulinda;

--
-- Name: promotion_campaign; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.promotion_campaign OWNER TO princelulinda;

--
-- Name: promotion_campaign_budget; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.promotion_campaign_budget OWNER TO princelulinda;

--
-- Name: promotion_campaign_budget_usage; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.promotion_campaign_budget_usage OWNER TO princelulinda;

--
-- Name: promotion_promotion_rule; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.promotion_promotion_rule (
    promotion_id text NOT NULL,
    promotion_rule_id text NOT NULL
);


ALTER TABLE public.promotion_promotion_rule OWNER TO princelulinda;

--
-- Name: promotion_rule; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.promotion_rule OWNER TO princelulinda;

--
-- Name: promotion_rule_value; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.promotion_rule_value (
    id text NOT NULL,
    promotion_rule_id text NOT NULL,
    value text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.promotion_rule_value OWNER TO princelulinda;

--
-- Name: provider_identity; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.provider_identity OWNER TO princelulinda;

--
-- Name: publishable_api_key_sales_channel; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.publishable_api_key_sales_channel (
    publishable_key_id character varying(255) NOT NULL,
    sales_channel_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.publishable_api_key_sales_channel OWNER TO princelulinda;

--
-- Name: push_token; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.push_token OWNER TO princelulinda;

--
-- Name: refund; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.refund OWNER TO princelulinda;

--
-- Name: refund_reason; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.refund_reason OWNER TO princelulinda;

--
-- Name: region; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.region OWNER TO princelulinda;

--
-- Name: region_country; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.region_country OWNER TO princelulinda;

--
-- Name: region_payment_provider; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.region_payment_provider (
    region_id character varying(255) NOT NULL,
    payment_provider_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.region_payment_provider OWNER TO princelulinda;

--
-- Name: reservation_item; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.reservation_item OWNER TO princelulinda;

--
-- Name: return; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.return OWNER TO princelulinda;

--
-- Name: return_display_id_seq; Type: SEQUENCE; Schema: public; Owner: princelulinda
--

CREATE SEQUENCE public.return_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.return_display_id_seq OWNER TO princelulinda;

--
-- Name: return_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: princelulinda
--

ALTER SEQUENCE public.return_display_id_seq OWNED BY public.return.display_id;


--
-- Name: return_fulfillment; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.return_fulfillment (
    return_id character varying(255) NOT NULL,
    fulfillment_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.return_fulfillment OWNER TO princelulinda;

--
-- Name: return_item; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.return_item OWNER TO princelulinda;

--
-- Name: return_reason; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.return_reason OWNER TO princelulinda;

--
-- Name: review; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.review (
    id text NOT NULL,
    product_id text NOT NULL,
    customer_id text NOT NULL,
    rating integer NOT NULL,
    content text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.review OWNER TO princelulinda;

--
-- Name: sales_channel; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.sales_channel OWNER TO princelulinda;

--
-- Name: sales_channel_stock_location; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.sales_channel_stock_location (
    sales_channel_id character varying(255) NOT NULL,
    stock_location_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.sales_channel_stock_location OWNER TO princelulinda;

--
-- Name: script_migrations; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.script_migrations (
    id integer NOT NULL,
    script_name character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    finished_at timestamp with time zone
);


ALTER TABLE public.script_migrations OWNER TO princelulinda;

--
-- Name: script_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: princelulinda
--

CREATE SEQUENCE public.script_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.script_migrations_id_seq OWNER TO princelulinda;

--
-- Name: script_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: princelulinda
--

ALTER SEQUENCE public.script_migrations_id_seq OWNED BY public.script_migrations.id;


--
-- Name: service_zone; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.service_zone OWNER TO princelulinda;

--
-- Name: shipping_option; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.shipping_option OWNER TO princelulinda;

--
-- Name: shipping_option_price_set; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.shipping_option_price_set (
    shipping_option_id character varying(255) NOT NULL,
    price_set_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.shipping_option_price_set OWNER TO princelulinda;

--
-- Name: shipping_option_rule; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.shipping_option_rule OWNER TO princelulinda;

--
-- Name: shipping_option_type; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.shipping_option_type OWNER TO princelulinda;

--
-- Name: shipping_profile; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.shipping_profile OWNER TO princelulinda;

--
-- Name: short_video; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.short_video OWNER TO princelulinda;

--
-- Name: stock_location; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.stock_location OWNER TO princelulinda;

--
-- Name: stock_location_address; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.stock_location_address OWNER TO princelulinda;

--
-- Name: store; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.store OWNER TO princelulinda;

--
-- Name: store_currency; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.store_currency OWNER TO princelulinda;

--
-- Name: store_locale; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.store_locale (
    id text NOT NULL,
    locale_code text NOT NULL,
    store_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.store_locale OWNER TO princelulinda;

--
-- Name: tax_provider; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.tax_provider (
    id text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.tax_provider OWNER TO princelulinda;

--
-- Name: tax_rate; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.tax_rate OWNER TO princelulinda;

--
-- Name: tax_rate_rule; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.tax_rate_rule OWNER TO princelulinda;

--
-- Name: tax_region; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.tax_region OWNER TO princelulinda;

--
-- Name: translation; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.translation OWNER TO princelulinda;

--
-- Name: translation_settings; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.translation_settings OWNER TO princelulinda;

--
-- Name: user; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public."user" OWNER TO princelulinda;

--
-- Name: user_preference; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.user_preference OWNER TO princelulinda;

--
-- Name: user_rbac_role; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.user_rbac_role (
    user_id character varying(255) NOT NULL,
    rbac_role_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.user_rbac_role OWNER TO princelulinda;

--
-- Name: vendor; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.vendor OWNER TO princelulinda;

--
-- Name: vendor_admin; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.vendor_admin OWNER TO princelulinda;

--
-- Name: video_comment; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.video_comment OWNER TO princelulinda;

--
-- Name: video_like; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.video_like (
    id text NOT NULL,
    video_id text NOT NULL,
    customer_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.video_like OWNER TO princelulinda;

--
-- Name: video_save; Type: TABLE; Schema: public; Owner: princelulinda
--

CREATE TABLE public.video_save (
    id text NOT NULL,
    video_id text NOT NULL,
    customer_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.video_save OWNER TO princelulinda;

--
-- Name: view_configuration; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.view_configuration OWNER TO princelulinda;

--
-- Name: workflow_execution; Type: TABLE; Schema: public; Owner: princelulinda
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


ALTER TABLE public.workflow_execution OWNER TO princelulinda;

--
-- Name: link_module_migrations id; Type: DEFAULT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.link_module_migrations ALTER COLUMN id SET DEFAULT nextval('public.link_module_migrations_id_seq'::regclass);


--
-- Name: mikro_orm_migrations id; Type: DEFAULT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.mikro_orm_migrations ALTER COLUMN id SET DEFAULT nextval('public.mikro_orm_migrations_id_seq'::regclass);


--
-- Name: order display_id; Type: DEFAULT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public."order" ALTER COLUMN display_id SET DEFAULT nextval('public.order_display_id_seq'::regclass);


--
-- Name: order_change_action ordering; Type: DEFAULT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_change_action ALTER COLUMN ordering SET DEFAULT nextval('public.order_change_action_ordering_seq'::regclass);


--
-- Name: order_claim display_id; Type: DEFAULT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_claim ALTER COLUMN display_id SET DEFAULT nextval('public.order_claim_display_id_seq'::regclass);


--
-- Name: order_exchange display_id; Type: DEFAULT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_exchange ALTER COLUMN display_id SET DEFAULT nextval('public.order_exchange_display_id_seq'::regclass);


--
-- Name: return display_id; Type: DEFAULT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.return ALTER COLUMN display_id SET DEFAULT nextval('public.return_display_id_seq'::regclass);


--
-- Name: script_migrations id; Type: DEFAULT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.script_migrations ALTER COLUMN id SET DEFAULT nextval('public.script_migrations_id_seq'::regclass);


--
-- Data for Name: account_holder; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.account_holder (id, provider_id, external_id, email, data, metadata, created_at, updated_at, deleted_at) FROM stdin;
acchld_01KSWZ94HFGMXS8Z8D3YATDQRX	pp_system_default	cus_01KSVPWBFY9T5MZXK47CYD788Q	princelulinda10@gmail.com	{}	\N	2026-05-30 19:35:31.888+02	2026-05-30 19:35:31.888+02	\N
acchld_01KSYNR3BVMPX2V3KKBG485GEQ	pp_system_default	cus_01KSR173ECD4A2AJF6H3R1H2J8	princelulinda32@gmail.com	{}	\N	2026-05-31 11:27:25.307+02	2026-05-31 11:27:25.307+02	\N
acchld_01KT9CPTPVBND0XMSK9CFGCAJH	pp_kashflow_kashflow	cus_01KSR173ECD4A2AJF6H3R1H2J8	princelulinda32@gmail.com	{"customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8"}	\N	2026-06-04 15:21:05.244+02	2026-06-04 15:21:05.244+02	\N
\.


--
-- Data for Name: analytics_event; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.analytics_event (id, product_id, vendor_id, source, campaign, event_type, order_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: api_key; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.api_key (id, token, salt, redacted, title, type, last_used_at, created_by, created_at, revoked_by, revoked_at, updated_at, deleted_at) FROM stdin;
apk_01KSCR9E4FPV3BZ6DTK9AQ9BCY	pk_9724ff03c87a78bd61b95498bd9e7fcad29484f546c654dcc1338ec68950f2d9		pk_972***2d9	Default Publishable API Key	publishable	\N		2026-05-24 12:25:30.767+02	\N	\N	2026-05-24 12:25:30.767+02	\N
apk_01KSCR9E9G4ZV5ENRXW1WS8XVC	pk_a7da09f6f330376b3513174f9a761990e8c0bba3c0563ba0efb4146f5db0458f		pk_a7d***58f	Webshop	publishable	\N		2026-05-24 12:25:30.928+02	\N	\N	2026-05-24 12:25:30.928+02	\N
\.


--
-- Data for Name: app_notification; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
01KSYZ52D15BNWAVC1826G4FP6	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_order	Commande confirmée	Votre commande #4 a été confirmée.	{"order_id": "order_01KSYZ528J6XCKJY7DR20SPNTZ", "display_id": 4}	f	2026-05-31 14:11:47.489+02	2026-05-31 14:11:47.489+02	\N
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
01KT1D4MZ2BK660FH04AXMYF3D	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	No	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 12:54:42.659+02	2026-06-01 12:54:42.659+02	\N
01KT1D5461DPDVJTCFG241N0EE	cus_01KSR173ECD4A2AJF6H3R1H2J8	customer	new_message	Nouveau message	Hello	{"sender_id": "01KSDE9JVTNAXE0NF67DNVEWBS", "sender_type": "vendor", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 12:54:58.241+02	2026-06-01 12:54:58.241+02	\N
01KT1DGQ2MTAXBWT80T20N9F98	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Hhhh	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-01 13:01:18.036+02	2026-06-01 13:01:18.036+02	\N
01KTEDDA6X9PRPZANZDRWSB36H	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_review	Nouveau avis	Un client a laissé un avis de 3 étoiles sur votre produit.	{"review_id": "01KTEDDA6QZ1PC9D4NF4H10JMD", "product_id": "prod_01KSDEEB3Y6W05F6K2ZV4GC0BM"}	f	2026-06-06 14:09:34.173+02	2026-06-06 14:09:34.173+02	\N
01KTEEM5NV7SDK47K4RR5629NZ	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Bo\n\n📦 Mapapa - 150 EUR	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-06 14:30:47.483+02	2026-06-06 14:30:47.483+02	\N
01KTFXC31JZMVJWFFC4CJYNEGR	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Bo	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-07 04:07:45.714+02	2026-06-07 04:07:45.714+02	\N
01KTFXGTSFQF6Q5KGSC1K7CE0Y	01KSDE9JVTNAXE0NF67DNVEWBS	vendor	new_message	Nouveau message	Bonjour	{"sender_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "sender_type": "customer", "conversation_id": "01KSS6HXREC788SEGBT87XV77M"}	f	2026-06-07 04:10:21.103+02	2026-06-07 04:10:21.103+02	\N
\.


--
-- Data for Name: application_method_buy_rules; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.application_method_buy_rules (application_method_id, promotion_rule_id) FROM stdin;
\.


--
-- Data for Name: application_method_target_rules; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.application_method_target_rules (application_method_id, promotion_rule_id) FROM stdin;
\.


--
-- Data for Name: auth_identity; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.auth_identity (id, app_metadata, created_at, updated_at, deleted_at) FROM stdin;
authid_01KSCRW56M4HHGZ62YKHD3GN8G	{"user_id": "user_01KSCRW542GHYQFHM9FB3QZM2J"}	2026-05-24 12:35:44.213+02	2026-05-24 12:35:44.219+02	\N
authid_01KSCS5ZMFWQ794DK9P2KTPC9H	{"vendor_id": "01KSCS6FHM3T088JTDVNHWEAP0"}	2026-05-24 12:41:06.192+02	2026-05-24 12:41:22.494+02	\N
authid_01KSCSTEDYTSQVWN8D97W0H5S6	{"vendor_id": "01KSCSTSPDSEAN744XV198F4RD"}	2026-05-24 12:52:16.702+02	2026-05-24 12:52:28.244+02	\N
authid_01KSDE84ASAVWY2BJH057MCBXY	{"vendor_id": "01KSDE9JW0MFK1W1NWQ29QV25V"}	2026-05-24 18:49:16.633+02	2026-05-24 18:50:04.293+02	\N
authid_01KSDGJHCTKACVMAMDBVGKA4AN	{"customer_id": "cus_01KSDGQE4N7DEJ0C3Q810Y8CYP"}	2026-05-24 19:29:54.843+02	2026-05-24 19:32:35.364+02	\N
authid_01KSQWK78GPYSWFDV5PD3K0GNQ	{"customer_id": "cus_01KSQWM10KJ2G0R75KZJYHDB6H"}	2026-05-28 20:12:24.464+02	2026-05-28 20:12:50.844+02	\N
authid_01KSR173CHW8REA4FMY690R5MR	{"customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8"}	2026-05-28 21:33:10.161+02	2026-05-28 21:33:10.23+02	\N
authid_01KSVPWAJ6G79SQV5S2Q26FGGG	{"customer_id": "cus_01KSVPWBFY9T5MZXK47CYD788Q"}	2026-05-30 07:49:29.03+02	2026-05-30 07:49:30.002+02	\N
authid_01KSWS7TY7W4PDKT3K7A9ZPYCK	{"customer_id": "cus_01KSWS7V39C4SDB1YTY9K83SMS"}	2026-05-30 17:49:57.831+02	2026-05-30 17:49:58.009+02	\N
authid_01KTEM0BVY5132SFAV1H149V4W	\N	2026-06-06 16:04:49.918+02	2026-06-06 16:04:49.918+02	\N
\.


--
-- Data for Name: capture; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.capture (id, amount, raw_amount, payment_id, created_at, updated_at, deleted_at, created_by, metadata) FROM stdin;
capt_01KSWZH7X99HJ1W6FV6MSAQTJS	10100	{"value": "10100", "precision": 20}	pay_01KSWZ94X29003ZASHHKTR2F82	2026-05-30 19:39:57.481+02	2026-05-30 19:39:57.481+02	\N	\N	\N
\.


--
-- Data for Name: cart; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: cart_address; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: cart_line_item; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: cart_line_item_adjustment; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.cart_line_item_adjustment (id, description, promotion_id, code, amount, raw_amount, provider_id, metadata, created_at, updated_at, deleted_at, item_id, is_tax_inclusive) FROM stdin;
\.


--
-- Data for Name: cart_line_item_tax_line; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.cart_line_item_tax_line (id, description, tax_rate_id, code, rate, provider_id, metadata, created_at, updated_at, deleted_at, item_id) FROM stdin;
\.


--
-- Data for Name: cart_payment_collection; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: cart_promotion; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.cart_promotion (cart_id, promotion_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: cart_shipping_method; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: cart_shipping_method_adjustment; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.cart_shipping_method_adjustment (id, description, promotion_id, code, amount, raw_amount, provider_id, metadata, created_at, updated_at, deleted_at, shipping_method_id) FROM stdin;
\.


--
-- Data for Name: cart_shipping_method_tax_line; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.cart_shipping_method_tax_line (id, description, tax_rate_id, code, rate, provider_id, metadata, created_at, updated_at, deleted_at, shipping_method_id) FROM stdin;
\.


--
-- Data for Name: conversation; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.conversation (id, customer_id, vendor_id, last_message_at, created_at, updated_at, deleted_at) FROM stdin;
01KSVVRRD4M51QGFJ12RKZN3V3	cus_01KSVPWBFY9T5MZXK47CYD788Q	01KSCS6FH5H9J6QY6ZPJ0110W5	2026-06-01 03:35:51.974+02	2026-05-30 09:14:55.013+02	2026-06-01 03:35:51.977+02	\N
01KSZCADYC4Z7KN64BXJ5023R1	cus_01KSVPWBFY9T5MZXK47CYD788Q	01KSDE9JVTNAXE0NF67DNVEWBS	2026-06-01 03:36:30.623+02	2026-05-31 18:01:54.636+02	2026-06-01 03:36:30.625+02	\N
01KSRC31WGAE8QWZC9PM6RMS3Y	cus_01KSR173ECD4A2AJF6H3R1H2J8	01KSCSTSP7N25SPSF2H5AK45FY	2026-05-29 13:01:51.598+02	2026-05-29 00:43:11.888+02	2026-05-29 13:01:51.6+02	\N
01KSDJSH13J278RNCTA18TBV4D	cus_01KSDGQE4N7DEJ0C3Q810Y8CYP	01KSDE9JVTNAXE0NF67DNVEWBS	2026-05-31 14:52:21.935+02	2026-05-24 20:08:40.996+02	2026-05-31 14:52:21.939+02	\N
01KSS6HXREC788SEGBT87XV77M	cus_01KSR173ECD4A2AJF6H3R1H2J8	01KSDE9JVTNAXE0NF67DNVEWBS	2026-06-07 04:10:21.092+02	2026-05-29 08:25:42.158+02	2026-06-07 04:10:21.094+02	\N
01KSZBM4SAZPVEQAZMQZFZ5NXG	cus_01KSWS7V39C4SDB1YTY9K83SMS	01KSDE9JVTNAXE0NF67DNVEWBS	2026-05-31 17:51:31.421+02	2026-05-31 17:49:44.362+02	2026-05-31 17:51:31.424+02	\N
\.


--
-- Data for Name: credit_line; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.credit_line (id, cart_id, reference, reference_id, amount, raw_amount, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: currency; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.customer (id, company_name, first_name, last_name, email, phone, has_account, metadata, created_at, updated_at, deleted_at, created_by) FROM stdin;
cus_01KSDGQE4N7DEJ0C3Q810Y8CYP	\N	prince	lulinda	princelulinda+890@gmail.com	66852137	t	\N	2026-05-24 19:32:35.35+02	2026-05-24 19:32:35.35+02	\N	\N
cus_01KSQWM10KJ2G0R75KZJYHDB6H	\N	Prince	lulinda	princelulinda78@gmail.com	666666777	t	\N	2026-05-28 20:12:50.835+02	2026-05-28 20:12:50.835+02	\N	\N
cus_01KSR173ECD4A2AJF6H3R1H2J8	\N	prince	lulinda	princelulinda32@gmail.com	76777777	t	\N	2026-05-28 21:33:10.221+02	2026-05-28 21:33:10.221+02	\N	\N
cus_01KSVPWBFY9T5MZXK47CYD788Q	\N	prince	-	princelulinda10@gmail.com	888888	t	\N	2026-05-30 07:49:29.982+02	2026-05-30 07:49:29.982+02	\N	\N
cus_01KSWS7V39C4SDB1YTY9K83SMS	\N	prince	crespo	princelulinda11@gmail.com	33666	t	\N	2026-05-30 17:49:57.993+02	2026-05-30 17:49:57.993+02	\N	\N
\.


--
-- Data for Name: customer_account_holder; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
cus_01KSR173ECD4A2AJF6H3R1H2J8	acchld_01KT9A1HQP5XRS6W9GMPECTSBB	custacchldr_01KT9A1HR2HBKYM5PCBV5QV3MQ	2026-06-04 14:34:30.785653+02	2026-06-04 14:34:33.247+02	2026-06-04 14:34:33.246+02
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
-- Data for Name: customer_address; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.customer_address (id, customer_id, address_name, is_default_shipping, is_default_billing, company, first_name, last_name, address_1, address_2, city, country_code, province, postal_code, phone, metadata, created_at, updated_at, deleted_at) FROM stdin;
cuaddr_01KSQXK0WBFKYBD6AJ31JFYEYE	cus_01KSQWM10KJ2G0R75KZJYHDB6H	\N	t	t	\N	Prince	lulinda	Line	Gifugwe	Gifurwe	bi	Bubanza			\N	2026-05-28 20:29:46.507+02	2026-05-28 20:29:55.733+02	\N
cuaddr_01KSR1BKSFHXS9Z8FXMA530N89	cus_01KSR173ECD4A2AJF6H3R1H2J8	\N	f	f	\N	prince	lulinda	Line		Musenyi	bi	Bubanza			\N	2026-05-28 21:35:38.031+02	2026-05-28 21:35:38.031+02	\N
cuaddr_01KSVPXDMC7X1M67T9QW4EJSHR	cus_01KSVPWBFY9T5MZXK47CYD788Q	\N	f	f	\N	prince	-	Line 1		Musenyi	bi	Bubanza			\N	2026-05-30 07:50:04.94+02	2026-05-30 07:50:04.94+02	\N
\.


--
-- Data for Name: customer_group; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.customer_group (id, name, metadata, created_by, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: customer_group_customer; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.customer_group_customer (id, customer_id, customer_group_id, metadata, created_at, updated_at, created_by, deleted_at) FROM stdin;
\.


--
-- Data for Name: customer_payment_method; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.customer_payment_method (id, customer_id, provider_id, data, is_default, label, created_at, updated_at, deleted_at) FROM stdin;
01KT1W29FPE0VRZ66289J2VBKH	cus_01KSR173ECD4A2AJF6H3R1H2J8	stripe	{"brand": "visa", "last4": "0000", "token": "tok_simulated"}	t	Visa	2026-06-01 17:15:34.007+02	2026-06-01 17:15:34.007+02	\N
\.


--
-- Data for Name: delivery_company; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.delivery_company (id, name, logo, phone, email, website, is_active, metadata, created_at, updated_at, deleted_at) FROM stdin;
01KTAF6PBVBWHD2ZQ97HZ5AZDA	FedEx	\N	+25767881752	princelulinda@gmail.com	\N	t	\N	2026-06-05 01:23:56.667+02	2026-06-05 01:23:56.667+02	\N
01KTAFPJ1FT8R49AAB3VPMTRVJ	DHL	\N	+25767881752	prinda@gmail.com	\N	t	\N	2026-06-05 01:32:36.528+02	2026-06-05 01:32:36.528+02	\N
\.


--
-- Data for Name: delivery_delivery_company_fulfillment_shipping_option; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
-- Data for Name: delivery_driver; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.delivery_driver (id, name, phone, vehicle_details, is_active, metadata, delivery_company_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: fulfillment; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.fulfillment (id, location_id, packed_at, shipped_at, delivered_at, canceled_at, data, provider_id, shipping_option_id, metadata, delivery_address_id, created_at, updated_at, deleted_at, marked_shipped_by, created_by, requires_shipping) FROM stdin;
ful_01KSYNRY5QE6WC9XE86D6X2MPW	sloc_01KSF7CHXY413KMNRYZAE8PT2S	2026-05-31 11:27:52.754+02	\N	\N	\N	{}	delivery-company-provider_delivery-company-provider	so_01KSWK0MGHVTE3D3GG9BEB4SYS	\N	fuladdr_01KSYNRY5Q7A8DEBKQTRWZ5E28	2026-05-31 11:27:52.759+02	2026-05-31 11:27:52.759+02	\N	\N	\N	t
ful_01KSYPWSFHJ0HXZSVH3G0SZ4WP	sloc_01KSF7CHXY413KMNRYZAE8PT2S	2026-05-31 11:47:27.596+02	2026-05-31 11:57:42.921+02	2026-05-31 12:04:49.001+02	\N	{}	delivery-company-provider_delivery-company-provider	so_01KSWK0MGHVTE3D3GG9BEB4SYS	\N	fuladdr_01KSYPWSFH0WJPY3XYP4M5F1NQ	2026-05-31 11:47:27.601+02	2026-05-31 12:04:49.016+02	\N	\N	\N	t
ful_01KSYGK32E7WQ4D5YNPM4C9H8C	sloc_01KSF7CHXY413KMNRYZAE8PT2S	2026-05-31 09:57:18.279+02	2026-06-01 09:40:48.88+02	\N	\N	{}	delivery-company-provider_delivery-company-provider	so_01KSWK0MGHVTE3D3GG9BEB4SYS	\N	fuladdr_01KSYGK32E35J1YC4JHGBPNB0X	2026-05-31 09:57:18.287+02	2026-06-01 09:40:48.894+02	\N	\N	\N	t
\.


--
-- Data for Name: fulfillment_address; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.fulfillment_address (id, company, first_name, last_name, address_1, address_2, city, country_code, province, postal_code, phone, metadata, created_at, updated_at, deleted_at) FROM stdin;
fuladdr_01KSYGK32E35J1YC4JHGBPNB0X	\N	prince	-	Line 1		Musenyi	bi	\N			\N	2026-05-30 19:35:22.079+02	2026-05-30 19:35:22.079+02	\N
fuladdr_01KSYNRY5Q7A8DEBKQTRWZ5E28	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-31 11:27:03.667+02	2026-05-31 11:27:03.667+02	\N
fuladdr_01KSYPWSFH0WJPY3XYP4M5F1NQ	\N	prince	lulinda	Line		Musenyi	bi	\N			\N	2026-05-31 11:46:43.692+02	2026-05-31 11:46:43.692+02	\N
\.


--
-- Data for Name: fulfillment_item; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.fulfillment_item (id, title, sku, barcode, quantity, raw_quantity, line_item_id, inventory_item_id, fulfillment_id, created_at, updated_at, deleted_at) FROM stdin;
fulit_01KSYGK32DN7GS1MNRH22TJGAQ	Rouge			1	{"value": "1", "precision": 20}	ordli_01KSWZ94QMZSFYTT7W2RETNS1N	iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	ful_01KSYGK32E7WQ4D5YNPM4C9H8C	2026-05-31 09:57:18.287+02	2026-05-31 09:57:18.287+02	\N
fulit_01KSYNRY5Q5GH2243WZXAYJ2QR	Rouge			1	{"value": "1", "precision": 20}	ordli_01KSYNR3FRS9WA22GY059T0G28	iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	ful_01KSYNRY5QE6WC9XE86D6X2MPW	2026-05-31 11:27:52.759+02	2026-05-31 11:27:52.759+02	\N
fulit_01KSYPWSFH6WRMREBJ75766Q0J	Rouge			3	{"value": "3", "precision": 20}	ordli_01KSYPW2RSYNTHG25MJ844X3J6	iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	ful_01KSYPWSFHJ0HXZSVH3G0SZ4WP	2026-05-31 11:47:27.601+02	2026-05-31 11:47:27.601+02	\N
\.


--
-- Data for Name: fulfillment_label; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.fulfillment_label (id, tracking_number, tracking_url, label_url, fulfillment_id, created_at, updated_at, deleted_at) FROM stdin;
fulla_01KSYQFJD1V2B08947A81H24KJ	NIB			ful_01KSYPWSFHJ0HXZSVH3G0SZ4WP	2026-05-31 11:57:42.946+02	2026-05-31 11:57:42.946+02	\N
\.


--
-- Data for Name: fulfillment_provider; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.fulfillment_provider (id, is_enabled, created_at, updated_at, deleted_at) FROM stdin;
delivery-company-provider_delivery-company-provider	t	2026-05-30 15:46:27.882+02	2026-05-30 15:46:27.882+02	\N
manual_manual	f	2026-05-24 12:23:06.721+02	2026-05-30 15:46:27.895+02	\N
\.


--
-- Data for Name: fulfillment_set; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.fulfillment_set (id, name, type, metadata, created_at, updated_at, deleted_at) FROM stdin;
fuset_01KSR2W2CKBZ3D4B3MB4Y2606S	Bujumbura shipping	shipping	\N	2026-05-28 22:02:05.843+02	2026-05-28 22:02:05.843+02	\N
fuset_01KSCR9E7DBG6TWATM3CH2T54A	European Warehouse delivery	shipping	\N	2026-05-24 12:25:30.861+02	2026-05-30 15:30:55.184+02	2026-05-30 15:30:55.183+02
fuset_01KSWJXMT5RA51MF8N6AK4SGNJ	Bujumbura pick up	pickup	\N	2026-05-30 15:59:32.421+02	2026-05-30 15:59:32.421+02	\N
\.


--
-- Data for Name: geo_zone; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
-- Data for Name: image; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: inventory_item; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: inventory_level; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
ilev_01KSF8JESJC2C9NG3QSXH2BFEX	2026-05-25 11:48:32.434+02	2026-06-05 10:42:12.461+02	\N	iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX	sloc_01KSF7CHXY413KMNRYZAE8PT2S	95	7	0	\N	{"value": "95", "precision": 20}	{"value": "7", "precision": 20}	{"value": "0", "precision": 20}
\.


--
-- Data for Name: invite; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.invite (id, email, accepted, token, expires_at, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: link_module_migrations; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
-- Data for Name: locale; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
-- Data for Name: location_fulfillment_provider; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.location_fulfillment_provider (stock_location_id, fulfillment_provider_id, id, created_at, updated_at, deleted_at) FROM stdin;
sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	manual_manual	locfp_01KSCR9E743K884XE1B3A66K59	2026-05-24 12:25:30.852533+02	2026-05-30 15:30:55.177+02	2026-05-30 15:30:55.176+02
sloc_01KSF7CHXY413KMNRYZAE8PT2S	delivery-company-provider_delivery-company-provider	locfp_01KSWJAJ3CA3EZHK292YHWYZ8W	2026-05-30 15:49:07.051456+02	2026-05-30 15:49:07.051456+02	\N
\.


--
-- Data for Name: location_fulfillment_set; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.location_fulfillment_set (stock_location_id, fulfillment_set_id, id, created_at, updated_at, deleted_at) FROM stdin;
sloc_01KSF7CHXY413KMNRYZAE8PT2S	fuset_01KSR2W2CKBZ3D4B3MB4Y2606S	locfs_01KSR2W2DAZJ45DGD9W4M3S7HP	2026-05-28 22:02:05.865701+02	2026-05-28 22:02:05.865701+02	\N
sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	fuset_01KSCR9E7DBG6TWATM3CH2T54A	locfs_01KSCR9E7MV2KQTVCDZB02FQ1P	2026-05-24 12:25:30.867833+02	2026-05-30 15:30:55.171+02	2026-05-30 15:30:55.17+02
sloc_01KSF7CHXY413KMNRYZAE8PT2S	fuset_01KSWJXMT5RA51MF8N6AK4SGNJ	locfs_01KSWJXMTVCR890GYVB9DX1RRY	2026-05-30 15:59:32.443254+02	2026-05-30 15:59:32.443254+02	\N
\.


--
-- Data for Name: marketplace_vendor_order_order; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: marketplace_vendor_product_product; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.marketplace_vendor_product_product (vendor_id, product_id, id, created_at, updated_at, deleted_at) FROM stdin;
01KSDE9JVTNAXE0NF67DNVEWBS	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	link_01KSDEEB69GSNW77MTA307205R	2026-05-24 18:52:40.265381+02	2026-05-24 18:52:40.265381+02	\N
01KSCSTSP7N25SPSF2H5AK45FY	prod_01KSH2A8YPQ2M4AN368YBJ9X3C	link_01KSH2A91JR3492ZSN6TJWAQRV	2026-05-26 04:37:41.810297+02	2026-05-26 04:37:41.810297+02	\N
01KSDE9JVTNAXE0NF67DNVEWBS	prod_01KT156V00QYP2NS7HYG4BWMYG	link_01KT156V6MZKDV945WXMDC2ZM4	2026-06-01 10:36:05.971865+02	2026-06-01 10:36:05.971865+02	\N
\.


--
-- Data for Name: marketplace_vendor_promotion_promotion; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.marketplace_vendor_promotion_promotion (vendor_id, promotion_id, id, created_at, updated_at, deleted_at) FROM stdin;
01KSDE9JVTNAXE0NF67DNVEWBS	promo_01KSFTYA07BW0AWQY1MGK5YPZ2	link_01KSFTYA1Y5BPQC490F9EZM19M	2026-05-25 17:09:35.166018+02	2026-05-25 17:09:35.166018+02	\N
01KSCSTSP7N25SPSF2H5AK45FY	promo_01KSSPF5WN97JJ7DAEWAWW9TQJ	link_01KSSPF5XHQJCN7PCE7FB7N5BA	2026-05-29 13:03:49.425618+02	2026-05-29 13:03:49.425618+02	\N
\.


--
-- Data for Name: marketplace_vendor_stock_location_stock_location; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.marketplace_vendor_stock_location_stock_location (vendor_id, stock_location_id, id, created_at, updated_at, deleted_at) FROM stdin;
01KSDE9JVTNAXE0NF67DNVEWBS	sloc_01KSF7CHXY413KMNRYZAE8PT2S	link_01KSF7CHYG372Y9YY98H6C3DHR	2026-05-25 11:27:50.480123+02	2026-05-25 11:27:50.480123+02	\N
\.


--
-- Data for Name: message; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.message (id, conversation_id, sender_type, sender_id, content, type, file_url, is_read, created_at, updated_at, deleted_at) FROM stdin;
01KSDJSN83YY52QZ0QNYN318RG	01KSDJSH13J278RNCTA18TBV4D	customer	cus_01KSDGQE4N7DEJ0C3Q810Y8CYP	What is the price?	text	\N	f	2026-05-24 20:08:45.315+02	2026-05-24 20:08:45.315+02	\N
01KSDK3RHSGNAYVCWJR3AEPQQS	01KSDJSH13J278RNCTA18TBV4D	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Bonjour	text	\N	f	2026-05-24 20:14:16.377+02	2026-05-24 20:14:16.377+02	\N
01KSDK5MRGCZBPDKCGSWD5ZY8H	01KSDJSH13J278RNCTA18TBV4D	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Maman	text	\N	f	2026-05-24 20:15:18.032+02	2026-05-24 20:15:18.032+02	\N
01KSDKAH6MCDSQ31TE2NVVR3TZ	01KSDJSH13J278RNCTA18TBV4D	customer	cus_01KSDGQE4N7DEJ0C3Q810Y8CYP	Is it available?	text	\N	f	2026-05-24 20:17:58.228+02	2026-05-24 20:17:58.228+02	\N
01KSDKB5KA3JQKPB7118CPYJBZ	01KSDJSH13J278RNCTA18TBV4D	customer	cus_01KSDGQE4N7DEJ0C3Q810Y8CYP		image	http://localhost:9000/static/1779646696595-image.jpg	f	2026-05-24 20:18:19.114+02	2026-05-24 20:18:19.114+02	\N
01KSF05ZH3M0D7Z6PTVGQQFCD2	01KSDJSH13J278RNCTA18TBV4D	customer	cus_01KSDGQE4N7DEJ0C3Q810Y8CYP	📦 Ma saani - 10000 EUR	image	http://localhost:9000/static/1779641482219-image.jpg	f	2026-05-25 09:21:54.979+02	2026-05-25 09:21:54.979+02	\N
01KSF09GTQ3Z7GRAAVRCY5Z0TZ	01KSDJSH13J278RNCTA18TBV4D	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Image	image	http://localhost:9000/static/1779693826275-image.jpg	f	2026-05-25 09:23:50.999+02	2026-05-25 09:23:50.999+02	\N
01KT0AXPJ8NFQEHHVZZ81VQ4WJ	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour, est-ce disponible ?	text	\N	t	2026-06-01 02:56:43.337+02	2026-06-01 03:00:15.678+02	\N
01KT0B05KSAFT9QX0BBSFR4PZJ	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Quel est le meilleur prix ?	text	\N	t	2026-06-01 02:58:04.282+02	2026-06-01 03:00:15.683+02	\N
01KSSPBJV91ZD1RMBT7WZ9TRH1	01KSRC31WGAE8QWZC9PM6RMS3Y	vendor	01KSCSTSP7N25SPSF2H5AK45FY	C'est 1000 USD	text	\N	t	2026-05-29 13:01:51.593+02	2026-06-01 03:07:02.399+02	\N
01KT0CRGAQ508803TPYZ2JN2MW	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Bonjour	image	http://localhost:9000/static/1780277325311-image.jpg	t	2026-06-01 03:28:50.263+02	2026-06-01 03:28:51.548+02	\N
01KT0DH51TNFCM46FY4D8706C8	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Quel est le meilleur prix ?	file	http://localhost:9000/static/1780278131707-1000020362.mp4	t	2026-06-01 03:42:17.914+02	2026-06-01 03:42:18.005+02	\N
01KT0DJBM349338AVWE2S3TKZ1	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8		image	http://localhost:9000/static/1780278173341-1000020644.jpg	t	2026-06-01 03:42:57.411+02	2026-06-01 03:42:57.865+02	\N
01KSZ1FBS229AZ0XDBSBME1JT1	01KSDJSH13J278RNCTA18TBV4D	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Je	text	\N	f	2026-05-31 14:52:21.923+02	2026-05-31 14:52:21.923+02	\N
01KSZCB0TS0PRHBR5QEY4YQCEE	01KSZCADYC4Z7KN64BXJ5023R1	customer	cus_01KSVPWBFY9T5MZXK47CYD788Q	Bonjour, est-ce disponible ?	text	\N	t	2026-05-31 18:02:13.978+02	2026-06-01 04:07:56.33+02	\N
01KT13RKJR53CG2V42NKYKNXS9	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Bb	text	\N	t	2026-06-01 10:10:50.841+02	2026-06-01 12:50:26.021+02	\N
01KT1DGQ1PEB185BR7ZRHKN9W7	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Hhhh	text	\N	t	2026-06-01 13:01:18.006+02	2026-06-01 13:01:43.868+02	\N
01KTEEM5N7BFFGAT2WPEN99RAY	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bo\n\n📦 Mapapa - 150 EUR	image	http://localhost:9000/static/1780302709862-image.jpg	f	2026-06-06 14:30:47.463+02	2026-06-06 14:30:47.463+02	\N
01KTFXC30WGX1KSHC1BMWC7HG6	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bo	text	\N	f	2026-06-07 04:07:45.693+02	2026-06-07 04:07:45.693+02	\N
01KTFXGTRZ58D5GGZBN4JJHTH9	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour	text	\N	f	2026-06-07 04:10:21.087+02	2026-06-07 04:10:21.087+02	\N
01KSSP8HWA4JV2KK5T98QZ6C99	01KSRC31WGAE8QWZC9PM6RMS3Y	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	C'est combien\n\n📦 Sufuria - 10000 EUR	image	http://localhost:9000/static/1779763040657-image.jpg	f	2026-05-29 13:00:12.298+02	2026-05-31 17:00:43.615+02	2026-05-31 17:00:43.614+02
01KSSP6A4W7NGVTMNBF490MVB9	01KSRC31WGAE8QWZC9PM6RMS3Y	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	What is the price?	text	\N	f	2026-05-29 12:58:58.844+02	2026-05-31 17:00:48.207+02	2026-05-31 17:00:48.206+02
01KSS3EHV2FX6944K0YMTJT5E7	01KSRC31WGAE8QWZC9PM6RMS3Y	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	What is the price?\n\n📦 Sufuria - 10000 EUR	image	http://localhost:9000/static/1779763040657-image.jpg	f	2026-05-29 07:31:25.922+02	2026-05-31 17:00:57.014+02	2026-05-31 17:00:57.014+02
01KSZBMBKZVY9KNQK8F4CAJSMN	01KSZBM4SAZPVEQAZMQZFZ5NXG	customer	cus_01KSWS7V39C4SDB1YTY9K83SMS	Bonjour, est-ce disponible ?	text	\N	f	2026-05-31 17:49:51.359+02	2026-05-31 17:49:51.359+02	\N
01KSZ8B41YXP82YJBPZGFDVH7S	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Hhhhhj	text	\N	t	2026-05-31 16:52:22.975+02	2026-06-01 01:36:17.049+02	\N
01KSZ8DGB6686Q8TDE9H82WFJ1	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	💡 Conseil pratique pour les langues africaines :\nIl est souvent préférable de créer ton propre dataset, car la plupart des datasets open-source ne contiennent pas assez de données pour ces langues.\nMême 5 à 10 heures de voix bien nettoyées peuvent donner un TTS de base correct.\nSi tu veux, je peux te �⁠faire un workflow complet étape par étape, �⁠avec tous les outils open-source pour créer un TTS en français africain ou toute langue africaine que tu vises.	text	\N	t	2026-05-31 16:53:41.094+02	2026-06-01 01:36:17.069+02	\N
01KSZBEZH2EEK2405CKH9NPAD0	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Hhhhjjjjjjjjjj	text	\N	t	2026-05-31 17:46:55.138+02	2026-06-01 01:36:17.081+02	\N
01KSYRKX3GJMT0EF5YSP4FS3NY	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Hello	text	\N	t	2026-05-31 12:17:33.552+02	2026-06-01 01:58:27.744+02	\N
01KSZ0WJRMGF991D581GR4224V	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	What is the price?	text	\N	t	2026-05-31 14:42:06.484+02	2026-06-01 01:58:27.746+02	\N
01KSZ11QPW6TNKX796GFT0ZB29	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	What is the price?	text	\N	t	2026-05-31 14:44:55.388+02	2026-06-01 01:58:27.774+02	\N
01KSZ12K60X4GQ456X1CADDRF1	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bon	text	\N	t	2026-05-31 14:45:23.52+02	2026-06-01 01:58:27.775+02	\N
01KSZ8AQ638D9567TMKQK9ZFJ1	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	What is the price?	text	\N	t	2026-05-31 16:52:09.795+02	2026-06-01 01:58:27.777+02	\N
01KSZ8E3SDHTG1REV1K4W6B81E	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	💡 Conseil pratique pour les langues africaines :\nIl est souvent préférable de créer ton propre dataset, car la plupart des datasets open-source ne contiennent pas assez de données pour ces langues.\nMême 5 à 10 heures de voix bien nettoyées peuvent donner un TTS de base correct.\nSi tu veux, je peux te �⁠faire un workflow complet étape par étape, �⁠avec tous les outils open-source pour créer un TTS en français africain ou toute langue africaine que tu vises.	text	\N	t	2026-05-31 16:54:01.005+02	2026-06-01 01:58:27.778+02	\N
01KSZAJ1R4CRD1EKZN3F41CAWZ	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour, est-ce disponible ?	text	\N	t	2026-05-31 17:31:07.14+02	2026-06-01 01:58:27.779+02	\N
01KSZAMMTDVBFJZZV9HN8D3176	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour \nJe ne sais	text	\N	t	2026-05-31 17:32:32.205+02	2026-06-01 01:58:27.782+02	\N
01KSZ1DJPMEGKBF739E2H0P4AZ	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Delivery time?	text	\N	t	2026-05-31 14:51:23.476+02	2026-06-01 01:58:27.788+02	\N
01KSZ13B63GHJEE2MV48JPWM3A	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	What is the price?	text	\N	t	2026-05-31 14:45:48.099+02	2026-06-01 01:58:27.79+02	\N
01KSZANCTEK6JM2RSXTD6WQYBJ	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Nnn	text	\N	t	2026-05-31 17:32:56.782+02	2026-06-01 01:58:27.818+02	\N
01KSZAPGYR5F4MG8VFM339Y4GH	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Combien coûte la livraison ?hh	text	\N	t	2026-05-31 17:33:33.784+02	2026-06-01 01:58:27.827+02	\N
01KSZBN164PE35GHJK5PBDVAKM	01KSZBM4SAZPVEQAZMQZFZ5NXG	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Hello	text	\N	f	2026-05-31 17:50:13.444+02	2026-05-31 17:50:13.444+02	\N
01KSZBQDAK11V64P2TB50HNSFM	01KSZBM4SAZPVEQAZMQZFZ5NXG	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Mmm	text	\N	f	2026-05-31 17:51:31.411+02	2026-05-31 17:51:31.411+02	\N
01KT0B34MZFAQMNS8C2M0AEHS1	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Pouvez-vous m'accorder une remise ?	text	\N	t	2026-06-01 02:59:41.599+02	2026-06-01 03:00:15.682+02	\N
01KT0BDK474D2EKYRPCZXKV2C8	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Kkkk	text	\N	t	2026-06-01 03:05:24.103+02	2026-06-01 03:07:10.458+02	\N
01KSZCCDC16T14CHZBGW39AG38	01KSZCADYC4Z7KN64BXJ5023R1	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Pi	text	\N	t	2026-05-31 18:02:59.585+02	2026-06-01 03:33:13.375+02	\N
01KSZCDSTM4PRXVJKWNAPZSSHT	01KSZCADYC4Z7KN64BXJ5023R1	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Nnnnn	text	\N	t	2026-05-31 18:03:45.108+02	2026-06-01 03:33:13.378+02	\N
01KSZE8M4R11A1HJS747ZD5KPA	01KSZCADYC4Z7KN64BXJ5023R1	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Ooooop	text	\N	t	2026-05-31 18:35:52.601+02	2026-06-01 03:33:13.378+02	\N
01KSZQ5SKTZHMXA52MGTHNVC19	01KSZCADYC4Z7KN64BXJ5023R1	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Hello	text	\N	t	2026-05-31 21:11:37.083+02	2026-06-01 03:33:13.38+02	\N
01KT0D5C4TTSFDRFF5XCM3X0ZC	01KSVVRRD4M51QGFJ12RKZN3V3	customer	cus_01KSVPWBFY9T5MZXK47CYD788Q	Quel est le meilleur prix ?	text	\N	f	2026-06-01 03:35:51.962+02	2026-06-01 03:35:58.121+02	2026-06-01 03:35:58.121+02
01KSZ71V2TQ7AN7MAFJ0Q24SQF	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Hello	text	\N	t	2026-05-31 16:29:50.299+02	2026-06-01 01:36:17.023+02	\N
01KSZ735RBPQPDRXA6FQ108H2Y	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Hello	text	\N	t	2026-05-31 16:30:33.995+02	2026-06-01 01:36:17.032+02	\N
01KSZ76DG9VGPC33TT0QDQKJPC	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Mmmm	text	\N	t	2026-05-31 16:32:20.234+02	2026-06-01 01:36:17.034+02	\N
01KSZ87JB7DD0DKNXFKDPARE2H	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Hé	text	\N	t	2026-05-31 16:50:26.535+02	2026-06-01 01:36:17.036+02	\N
01KSZ892Y893GTFSH8VRC3P8BW	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Jjjjjj	text	\N	t	2026-05-31 16:51:16.298+02	2026-06-01 01:36:17.038+02	\N
01KSZ8FSHM4XBCTMF2GXZEXST9	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	💡 Conseil pratique pour les langues africaines :\nIl est souvent préférable de créer ton propre dataset, car la plupart des datasets open-source ne contiennent pas assez de données pour ces langues.\nMême 5 à 10 heures de voix bien nettoyées peuvent donner un TTS de base correct.\nSi tu veux, je peux te �⁠faire un workflow complet étape par étape, �⁠avec tous les outils open-source pour créer un TTS en français africain ou toute langue africaine que tu vises.	text	\N	t	2026-05-31 16:54:56.053+02	2026-06-01 01:36:17.071+02	\N
01KSZAQRYK7KZ964PDMKH2KSKM	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Bonjour	text	\N	t	2026-05-31 17:34:14.739+02	2026-06-01 01:36:17.073+02	\N
01KSZAYDH0TSQN0ZM75XC1BPPS	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	🙂‍↔️	text	\N	t	2026-05-31 17:37:52.416+02	2026-06-01 01:36:17.075+02	\N
01KT01G83FR8V8Y7VJ9J8DX033	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Oooo	text	\N	t	2026-06-01 00:12:05.359+02	2026-06-01 01:36:17.089+02	\N
01KT02SSG7ASSEQP7BVYNJCQW4	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Nnnn	text	\N	t	2026-06-01 00:34:46.664+02	2026-06-01 01:36:17.092+02	\N
01KT03762XZDEV0HR0M43HNVN5	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Iiii	text	\N	t	2026-06-01 00:42:05.533+02	2026-06-01 01:36:17.098+02	\N
01KT03FQX53M0D8AAKGJ7T51Z5	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Ggg	text	\N	t	2026-06-01 00:46:45.925+02	2026-06-01 01:36:17.101+02	\N
01KSZD4ZJHY2AZDPRM2TTV5JYC	01KSZCADYC4Z7KN64BXJ5023R1	customer	cus_01KSVPWBFY9T5MZXK47CYD788Q	Quel est le meilleur prix ?	text	\N	f	2026-05-31 18:16:24.658+02	2026-06-01 03:36:10.532+02	2026-06-01 03:36:10.532+02
01KSZCVVKQDNR8ZV8J5RQ2S8MQ	01KSZCADYC4Z7KN64BXJ5023R1	customer	cus_01KSVPWBFY9T5MZXK47CYD788Q	Quel est le meilleur prix ?	text	\N	f	2026-05-31 18:11:25.688+02	2026-06-01 03:36:14.689+02	2026-06-01 03:36:14.689+02
01KSZCPYST72W49Q469X76YYR7	01KSZCADYC4Z7KN64BXJ5023R1	customer	cus_01KSVPWBFY9T5MZXK47CYD788Q	Quel est le meilleur prix ?	text	\N	f	2026-05-31 18:08:45.115+02	2026-06-01 03:36:18.421+02	2026-06-01 03:36:18.421+02
01KT06CW47TTCAX85W9HBGM1GB	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Iijjjj	text	\N	t	2026-06-01 01:37:37.672+02	2026-06-01 01:37:37.717+02	\N
01KT06D6W6F5D4R64D3RKR3WQ7	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Jjjnjj	text	\N	t	2026-06-01 01:37:48.679+02	2026-06-01 01:37:49.848+02	\N
01KSZCG5ANG10NR1YX16E8G33V	01KSZCADYC4Z7KN64BXJ5023R1	customer	cus_01KSVPWBFY9T5MZXK47CYD788Q	Quel est le meilleur prix ?	text	\N	t	2026-05-31 18:05:02.421+02	2026-06-01 04:07:56.326+02	\N
01KT06H6VQ0M09VBXVZJGRQ6MA	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Papa	text	\N	t	2026-06-01 01:39:59.735+02	2026-06-01 01:42:50.93+02	\N
01KT071W5N0K7QDXXGR3XRDVD5	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Mama	text	\N	t	2026-06-01 01:49:05.845+02	2026-06-01 01:49:11.884+02	\N
01KSZ1EEHXE87G8T8KRFS8BD1G	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	What is the price?	image	http://localhost:9000/static/1780231908696-image.jpg	t	2026-05-31 14:51:51.997+02	2026-06-01 01:58:27.784+02	\N
01KSZAMWEVA8JMGZ9CM2AR5653	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Pouvez-vous m'accorder une remise ?	text	\N	t	2026-05-31 17:32:40.028+02	2026-06-01 01:58:27.795+02	\N
01KT01EMM5PTHRHBH78C8SS1Y6	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour, est-ce disponible ?	text	\N	t	2026-06-01 00:11:12.645+02	2026-06-01 01:58:27.831+02	\N
01KT01H60PVSV2MM7KZYKHMMN2	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Quel est le meilleur prix ?	text	\N	t	2026-06-01 00:12:35.991+02	2026-06-01 01:58:27.832+02	\N
01KT038K57NS4Y2GMHZDN9JDC7	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour, est-ce disponible ?	text	\N	t	2026-06-01 00:42:51.687+02	2026-06-01 01:58:27.834+02	\N
01KT059HVQ8C0V47VVPVADMWG9	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour, est-ce disponible ?	text	\N	t	2026-06-01 01:18:20.28+02	2026-06-01 01:58:27.835+02	\N
01KT067TAGP24139Z1N5P2CE44	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour, est-ce disponible ?	text	\N	t	2026-06-01 01:34:51.985+02	2026-06-01 01:58:27.844+02	\N
01KT0698XTKEJET9EYZ4WEPVNE	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour, est-ce disponible ?	text	\N	t	2026-06-01 01:35:39.706+02	2026-06-01 01:58:27.846+02	\N
01KT06BA1WQ2GNH7MF1E1PZX5F	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour, est-ce disponible ?	text	\N	t	2026-06-01 01:36:46.396+02	2026-06-01 01:58:27.852+02	\N
01KT06DWA2Z3CDNFECNXBSB0VR	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour, est-ce disponible ?	text	\N	t	2026-06-01 01:38:10.627+02	2026-06-01 01:58:27.859+02	\N
01KT06CD69P96YERDYY70P9A76	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Hjjjjjkk	text	\N	t	2026-06-01 01:37:22.377+02	2026-06-01 01:58:27.86+02	\N
01KT06QAV38PWYHT2HWZK6KE0D	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Quel est le meilleur prix ?	text	\N	t	2026-06-01 01:43:20.419+02	2026-06-01 01:58:27.861+02	\N
01KT07KGC71GS43DMFJ1V42D5Q	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Hhh	text	\N	t	2026-06-01 01:58:43.591+02	2026-06-01 01:58:44.589+02	\N
01KT0B4GQGADF366EY5H14KFRT	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Kkk	text	\N	t	2026-06-01 03:00:26.736+02	2026-06-01 03:00:27.77+02	\N
01KT07KXPH64YN8MRXG6E160CZ	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour, est-ce disponible ?	text	\N	t	2026-06-01 01:58:57.234+02	2026-06-01 01:58:57.365+02	\N
01KT07P27KGCW2NZ2VREF6QPA4	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Hello	text	\N	t	2026-06-01 02:00:07.411+02	2026-06-01 02:00:08.364+02	\N
01KT0B56YNVVB3KDJXVQ6J0B45	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Nnn	text	\N	t	2026-06-01 03:00:49.493+02	2026-06-01 03:00:49.532+02	\N
01KT07Q1E2KGFXRQ1ZRBF9EDCQ	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Kjjjjjjjjjhhhjkkjhhhggggggggggghhh	text	\N	t	2026-06-01 02:00:39.363+02	2026-06-01 02:00:39.411+02	\N
01KT0B664DFFJGAQ0T13E2YFN7	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Nnjj	text	\N	t	2026-06-01 03:01:21.421+02	2026-06-01 03:07:10.437+02	\N
01KT0B6YH1PT5AJRENXAMHKD7X	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Mmmm	text	\N	t	2026-06-01 03:01:46.401+02	2026-06-01 03:07:10.438+02	\N
01KT08261GQHEGVT9BR1MKS1VM	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Mmm	text	\N	t	2026-06-01 02:06:44.529+02	2026-06-01 02:20:25.17+02	\N
01KT0849R1TZ5MMFGM4D1100RX	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Quel est le meilleur prix ?	text	\N	t	2026-06-01 02:07:53.858+02	2026-06-01 02:20:25.18+02	\N
01KT08EHA0CE186GS5X3ZQ7CZ0	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Quel est le meilleur prix ?	text	\N	t	2026-06-01 02:13:29.28+02	2026-06-01 02:20:25.191+02	\N
01KT08H9R678HMDHGNWGPYATFZ	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour, est-ce disponible ?	text	\N	t	2026-06-01 02:14:59.846+02	2026-06-01 02:20:25.197+02	\N
01KT08KKZ8YK61H6M7MAKGC62Y	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Pouvez-vous m'accorder une remise ?	text	\N	t	2026-06-01 02:16:15.849+02	2026-06-01 02:20:25.21+02	\N
01KT08M34QQXFRF1VCCHZ2HJYA	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Nnn	text	\N	t	2026-06-01 02:16:31.383+02	2026-06-01 02:20:25.218+02	\N
01KT08M34VK14H4XHQSP68GFN3	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Nnn	text	\N	t	2026-06-01 02:16:31.387+02	2026-06-01 02:20:25.22+02	\N
01KT0B82S3XJJEA5R73XWDH3V6	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Kkk	text	\N	t	2026-06-01 03:02:23.523+02	2026-06-01 03:07:10.447+02	\N
01KT0B7B5C7STK76M3PKD5NBEQ	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Jkk	text	\N	t	2026-06-01 03:01:59.34+02	2026-06-01 03:07:10.452+02	\N
01KT0B8VXMT6MXWYKQQCKTYVRX	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Kik	text	\N	t	2026-06-01 03:02:49.268+02	2026-06-01 03:07:10.454+02	\N
01KT08VEE8PYW7A7VNPTC1HYE3	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Uu	text	\N	t	2026-06-01 02:20:32.328+02	2026-06-01 02:26:05.563+02	\N
01KT08XKAQAV16ZPPKWSX7AKWM	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Hhh	text	\N	t	2026-06-01 02:21:42.871+02	2026-06-01 02:26:05.569+02	\N
01KT08YB7YS2BD7NWN20Q3F5VT	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	No	text	\N	t	2026-06-01 02:22:07.358+02	2026-06-01 02:26:05.59+02	\N
01KT090YMC0XNMN542V68N66AE	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Jjjjj	text	\N	t	2026-06-01 02:23:32.748+02	2026-06-01 02:26:05.592+02	\N
01KT0959JFRWXNQSV6MGH6HA4T	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Bbbbn	text	\N	t	2026-06-01 02:25:55.023+02	2026-06-01 02:26:05.594+02	\N
01KT0D6HWMJS0VE8K9KQ154A57	01KSZCADYC4Z7KN64BXJ5023R1	customer	cus_01KSVPWBFY9T5MZXK47CYD788Q	Bonjour, est-ce disponible ?	text	\N	t	2026-06-01 03:36:30.612+02	2026-06-01 04:07:56.329+02	\N
01KSZCDGW0459W7CVZ2F35CZ4R	01KSZCADYC4Z7KN64BXJ5023R1	customer	cus_01KSVPWBFY9T5MZXK47CYD788Q	Bonjour, est-ce disponible ?	text	\N	t	2026-05-31 18:03:35.937+02	2026-06-01 04:07:56.332+02	\N
01KT095ZANNQBYE86C13TY575D	01KSS6HXREC788SEGBT87XV77M	customer	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour, est-ce disponible ?	text	\N	t	2026-06-01 02:26:17.301+02	2026-06-01 02:47:56.403+02	\N
01KT0AFYQENMC7JF9VR6SHW7C5	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Oooo	text	\N	t	2026-06-01 02:49:12.942+02	2026-06-01 02:53:58.436+02	\N
01KT0ACTMXYZTKE11X813MFSNF	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Aws	text	\N	t	2026-06-01 02:47:30.461+02	2026-06-01 02:53:58.439+02	\N
01KT0EYR06ZKRGGZ9TYZVH8B9N	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS		file	http://localhost:9000/static/1780279627320-video_1780279624693.mp4	t	2026-06-01 04:07:11.878+02	2026-06-01 12:50:26.014+02	\N
01KT1D3TFVR1BNJGVYNS8BHWW6	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Bonjour	text	\N	t	2026-06-01 12:54:15.547+02	2026-06-01 12:55:11.154+02	\N
01KT1D5455T90ZJ9G1NXDPE5WY	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	Hello	text	\N	t	2026-06-01 12:54:58.213+02	2026-06-01 12:55:11.158+02	\N
01KT1D4MYC5X4VH2SMTTB4AGQR	01KSS6HXREC788SEGBT87XV77M	vendor	01KSDE9JVTNAXE0NF67DNVEWBS	No	text	\N	t	2026-06-01 12:54:42.637+02	2026-06-01 12:55:11.159+02	\N
\.


--
-- Data for Name: mikro_orm_migrations; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: notification; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.notification (id, "to", channel, template, data, trigger_type, resource_id, resource_type, receiver_id, original_notification_id, idempotency_key, external_id, provider_id, created_at, updated_at, deleted_at, status, "from", provider_data) FROM stdin;
\.


--
-- Data for Name: notification_provider; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.notification_provider (id, handle, name, is_enabled, channels, created_at, updated_at, deleted_at) FROM stdin;
local	local	local	t	{feed}	2026-05-24 12:23:06.72+02	2026-05-24 12:23:06.72+02	\N
\.


--
-- Data for Name: order; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public."order" (id, region_id, display_id, customer_id, version, sales_channel_id, status, is_draft_order, email, currency_code, shipping_address_id, billing_address_id, no_notification, metadata, created_at, updated_at, deleted_at, canceled_at, custom_display_id, locale) FROM stdin;
order_01KSYNR3FQYDZ176SCBXMTC2CA	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	2	cus_01KSR173ECD4A2AJF6H3R1H2J8	2	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pending	f	princelulinda32@gmail.com	usd	ordaddr_01KSYNR3FN03GDG9077C2C6GXP	\N	f	\N	2026-05-31 11:27:25.432+02	2026-05-31 11:27:52.798+02	\N	\N	\N	\N
order_01KSYPW2RSZ248CCQ1F6HZEQJ5	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	3	cus_01KSR173ECD4A2AJF6H3R1H2J8	4	sc_01KSCR9E3HDNX82KGM4FXZDGP1	completed	f	princelulinda32@gmail.com	usd	ordaddr_01KSYPW2RRF7E5T4J9ZWDDGZMK	\N	f	\N	2026-05-31 11:47:04.346+02	2026-05-31 12:04:49.1+02	\N	\N	\N	\N
order_01KSYZ528J6XCKJY7DR20SPNTZ	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	4	cus_01KSR173ECD4A2AJF6H3R1H2J8	1	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pending	f	princelulinda32@gmail.com	usd	ordaddr_01KSYZ528GR7ZSD3GYJBZK4DEP	\N	f	\N	2026-05-31 14:11:47.347+02	2026-05-31 14:11:47.347+02	\N	\N	\N	\N
order_01KSYZ9NKNR0ZFP1NHRRJ6C4H0	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	5	cus_01KSR173ECD4A2AJF6H3R1H2J8	1	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pending	f	princelulinda32@gmail.com	usd	ordaddr_01KSYZ9NKJKQY8SZ2KEJNN9RCF	\N	f	\N	2026-05-31 14:14:18.231+02	2026-05-31 14:14:18.231+02	\N	\N	\N	\N
order_01KSYZEHBJT6J0R02PCEWAQXYW	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	6	cus_01KSR173ECD4A2AJF6H3R1H2J8	1	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pending	f	princelulinda32@gmail.com	usd	ordaddr_01KSYZEHBF966Q5JSBGGV5XJF4	\N	f	\N	2026-05-31 14:16:57.716+02	2026-05-31 14:16:57.716+02	\N	\N	\N	\N
order_01KSZ025ATTT8ABSP8NXJK5XXH	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	7	cus_01KSR173ECD4A2AJF6H3R1H2J8	1	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pending	f	princelulinda32@gmail.com	usd	ordaddr_01KSZ025AQANEFSPPBX92GTKZH	\N	f	\N	2026-05-31 14:27:40.764+02	2026-05-31 14:27:40.764+02	\N	\N	\N	\N
order_01KSZ040QG8CAWV63TQC132B9P	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	8	cus_01KSR173ECD4A2AJF6H3R1H2J8	1	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pending	f	princelulinda32@gmail.com	usd	ordaddr_01KSZ040QCCTEJA9TQ42SPCTFD	\N	f	\N	2026-05-31 14:28:41.586+02	2026-05-31 14:28:41.586+02	\N	\N	\N	\N
order_01KSZ0VB193K4QY97BW6PNNHWE	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	9	cus_01KSR173ECD4A2AJF6H3R1H2J8	1	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pending	f	princelulinda32@gmail.com	usd	ordaddr_01KSZ0VB18BE38HMDS9C4AAQ4T	\N	f	\N	2026-05-31 14:41:25.803+02	2026-05-31 14:41:25.803+02	\N	\N	\N	\N
order_01KSWZ94QHBKV096ESCTPKNS2N	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	1	cus_01KSR173ECD4A2AJF6H3R1H2J8	3	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pending	f	princelulinda10@gmail.com	usd	ordaddr_01KSWZ94QBFWCV23FQSBGT6K3B	\N	f	\N	2026-05-30 19:35:32.087+02	2026-06-01 09:40:48.922+02	\N	\N	\N	\N
\.


--
-- Data for Name: order_address; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: order_cart; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: order_change; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
-- Data for Name: order_change_action; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
-- Data for Name: order_claim; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.order_claim (id, order_id, return_id, order_version, display_id, type, no_notification, refund_amount, raw_refund_amount, metadata, created_at, updated_at, deleted_at, canceled_at, created_by) FROM stdin;
\.


--
-- Data for Name: order_claim_item; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.order_claim_item (id, claim_id, item_id, is_additional_item, reason, quantity, raw_quantity, note, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_claim_item_image; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.order_claim_item_image (id, claim_item_id, url, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_credit_line; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.order_credit_line (id, order_id, reference, reference_id, amount, raw_amount, metadata, created_at, updated_at, deleted_at, version) FROM stdin;
\.


--
-- Data for Name: order_exchange; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.order_exchange (id, order_id, return_id, order_version, display_id, no_notification, allow_backorder, difference_due, raw_difference_due, metadata, created_at, updated_at, deleted_at, canceled_at, created_by) FROM stdin;
\.


--
-- Data for Name: order_exchange_item; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.order_exchange_item (id, exchange_id, item_id, quantity, raw_quantity, note, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_fulfillment; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.order_fulfillment (order_id, fulfillment_id, id, created_at, updated_at, deleted_at) FROM stdin;
order_01KSWZ94QHBKV096ESCTPKNS2N	ful_01KSYGK32E7WQ4D5YNPM4C9H8C	ordful_01KSYGK33G6VFDC7F98TMQ1XJX	2026-05-31 09:57:18.319516+02	2026-05-31 09:57:18.319516+02	\N
order_01KSYNR3FQYDZ176SCBXMTC2CA	ful_01KSYNRY5QE6WC9XE86D6X2MPW	ordful_01KSYNRY69VA983WT8X1TXKBT8	2026-05-31 11:27:52.777061+02	2026-05-31 11:27:52.777061+02	\N
order_01KSYPW2RSZ248CCQ1F6HZEQJ5	ful_01KSYPWSFHJ0HXZSVH3G0SZ4WP	ordful_01KSYPWSG2A1NXZERWT5ZMQ0JM	2026-05-31 11:47:27.617527+02	2026-05-31 11:47:27.617527+02	\N
\.


--
-- Data for Name: order_item; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: order_line_item; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: order_line_item_adjustment; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.order_line_item_adjustment (id, description, promotion_id, code, amount, raw_amount, provider_id, created_at, updated_at, item_id, deleted_at, is_tax_inclusive, version) FROM stdin;
\.


--
-- Data for Name: order_line_item_tax_line; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.order_line_item_tax_line (id, description, tax_rate_id, code, rate, raw_rate, provider_id, created_at, updated_at, item_id, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_payment_collection; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: order_promotion; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.order_promotion (order_id, promotion_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_shipping; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: order_shipping_method; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: order_shipping_method_adjustment; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.order_shipping_method_adjustment (id, description, promotion_id, code, amount, raw_amount, provider_id, created_at, updated_at, shipping_method_id, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_shipping_method_tax_line; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.order_shipping_method_tax_line (id, description, tax_rate_id, code, rate, raw_rate, provider_id, created_at, updated_at, shipping_method_id, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_summary; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: order_transaction; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.order_transaction (id, order_id, version, amount, raw_amount, currency_code, reference, reference_id, created_at, updated_at, deleted_at, return_id, claim_id, exchange_id) FROM stdin;
ordtrx_01KSWZH7Z9QV231MJ0K3ZX3Y5G	order_01KSWZ94QHBKV096ESCTPKNS2N	1	10100	{"value": "10100", "precision": 20}	usd	capture	capt_01KSWZH7X99HJ1W6FV6MSAQTJS	2026-05-30 19:39:57.557+02	2026-05-30 19:39:57.557+02	\N	\N	\N	\N
\.


--
-- Data for Name: payment; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: payment_collection; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
pay_col_01KT6M0W172PCB6JW5MG36TPT6	usd	20030	{"value": "20030", "precision": 20}	\N	\N	\N	\N	\N	\N	2026-06-03 13:31:11.016+02	2026-06-06 14:32:02.969+02	\N	\N	not_paid	\N
\.


--
-- Data for Name: payment_collection_payment_providers; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.payment_collection_payment_providers (payment_collection_id, payment_provider_id) FROM stdin;
\.


--
-- Data for Name: payment_provider; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
-- Data for Name: payment_session; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.payment_session (id, currency_code, amount, raw_amount, provider_id, data, context, status, authorized_at, payment_collection_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
payses_01KSWZ94J7CY6729VA2K78547P	usd	10100	{"value": "10100", "precision": 20}	pp_system_default	{}	{"customer": {"id": "cus_01KSVPWBFY9T5MZXK47CYD788Q", "email": "princelulinda10@gmail.com", "phone": "888888", "metadata": null, "addresses": [{"id": "cuaddr_01KSVPXDMC7X1M67T9QW4EJSHR", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line 1", "address_2": "", "last_name": "-", "created_at": "2026-05-30T05:50:04.940Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-30T05:50:04.940Z", "customer_id": "cus_01KSVPWBFY9T5MZXK47CYD788Q", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}], "last_name": "-", "first_name": "prince", "company_name": null, "account_holders": [], "billing_address": {"id": "cuaddr_01KSVPXDMC7X1M67T9QW4EJSHR", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line 1", "address_2": "", "last_name": "-", "created_at": "2026-05-30T05:50:04.940Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-30T05:50:04.940Z", "customer_id": "cus_01KSVPWBFY9T5MZXK47CYD788Q", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}}, "account_holder": {"id": "acchld_01KSWZ94HFGMXS8Z8D3YATDQRX", "data": {}, "email": "princelulinda10@gmail.com", "metadata": null, "created_at": "2026-05-30T17:35:31.888Z", "deleted_at": null, "updated_at": "2026-05-30T17:35:31.888Z", "external_id": "cus_01KSVPWBFY9T5MZXK47CYD788Q", "provider_id": "pp_system_default"}}	authorized	2026-05-30 19:35:32.251+02	pay_col_01KSWZ94EQ5D38QNM7MST6HWZG	{}	2026-05-30 19:35:31.912+02	2026-05-30 19:35:32.259+02	\N
payses_01KSYNR3C7W7WCX69YZ5NTDW78	usd	10100	{"value": "10100", "precision": 20}	pp_system_default	{}	{"customer": {"id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "email": "princelulinda32@gmail.com", "phone": "76777777", "metadata": null, "addresses": [{"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}], "last_name": "lulinda", "first_name": "prince", "company_name": null, "account_holders": [], "billing_address": {"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}}, "account_holder": {"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}}	authorized	2026-05-31 11:27:25.471+02	pay_col_01KSYNR39BDXK25THEAVTSYRGS	{}	2026-05-31 11:27:25.319+02	2026-05-31 11:27:25.473+02	\N
payses_01KSYPW2P5TNXWN70T3BHAVG19	usd	30100	{"value": "30100", "precision": 20}	pp_system_default	{}	{"customer": {"id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "email": "princelulinda32@gmail.com", "phone": "76777777", "metadata": null, "addresses": [{"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}], "last_name": "lulinda", "first_name": "prince", "company_name": null, "account_holders": [{"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}], "billing_address": {"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}}, "account_holder": {"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}}	authorized	2026-05-31 11:47:04.4+02	pay_col_01KSYPW2KYHN8K2GHSVKVXMBZG	{}	2026-05-31 11:47:04.261+02	2026-05-31 11:47:04.402+02	\N
payses_01KSYZ5226WMATPAM6S2DGJZ1X	usd	10100	{"value": "10100", "precision": 20}	pp_system_default	{}	{"customer": {"id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "email": "princelulinda32@gmail.com", "phone": "76777777", "metadata": null, "addresses": [{"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}], "last_name": "lulinda", "first_name": "prince", "company_name": null, "account_holders": [{"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}], "billing_address": {"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}}, "account_holder": {"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}}	authorized	2026-05-31 14:11:47.402+02	pay_col_01KSYZ51Q4494HTGSD1TJ8A5D2	{}	2026-05-31 14:11:47.143+02	2026-05-31 14:11:47.406+02	\N
payses_01KSYZ9NF83CBN9KVKS0KCRXH5	usd	10100	{"value": "10100", "precision": 20}	pp_system_default	{}	{"customer": {"id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "email": "princelulinda32@gmail.com", "phone": "76777777", "metadata": null, "addresses": [{"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}], "last_name": "lulinda", "first_name": "prince", "company_name": null, "account_holders": [{"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}], "billing_address": {"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}}, "account_holder": {"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}}	authorized	2026-05-31 14:14:18.279+02	pay_col_01KSYZ9NDFGXQM8FA9J9W7D3JD	{}	2026-05-31 14:14:18.088+02	2026-05-31 14:14:18.282+02	\N
payses_01KSYZEH8VP23SR6003EK0R1NB	usd	20100	{"value": "20100", "precision": 20}	pp_system_default	{}	{"customer": {"id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "email": "princelulinda32@gmail.com", "phone": "76777777", "metadata": null, "addresses": [{"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}], "last_name": "lulinda", "first_name": "prince", "company_name": null, "account_holders": [{"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}], "billing_address": {"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}}, "account_holder": {"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}}	authorized	2026-05-31 14:16:57.767+02	pay_col_01KSYZEH789VJTB2YQF9KHSJWZ	{}	2026-05-31 14:16:57.627+02	2026-05-31 14:16:57.769+02	\N
payses_01KSZ025785Q26NP2ZV88X2G2R	usd	10100	{"value": "10100", "precision": 20}	pp_system_default	{}	{"customer": {"id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "email": "princelulinda32@gmail.com", "phone": "76777777", "metadata": null, "addresses": [{"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}], "last_name": "lulinda", "first_name": "prince", "company_name": null, "account_holders": [{"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}], "billing_address": {"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}}, "account_holder": {"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}}	authorized	2026-05-31 14:27:40.838+02	pay_col_01KSZ02556JBB1TV51D0S5K6Y9	{}	2026-05-31 14:27:40.648+02	2026-05-31 14:27:40.843+02	\N
payses_01KSZ040MJ95CZEF9WZ1X1B5J6	usd	10100	{"value": "10100", "precision": 20}	pp_system_default	{}	{"customer": {"id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "email": "princelulinda32@gmail.com", "phone": "76777777", "metadata": null, "addresses": [{"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}], "last_name": "lulinda", "first_name": "prince", "company_name": null, "account_holders": [{"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}], "billing_address": {"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}}, "account_holder": {"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}}	authorized	2026-05-31 14:28:41.647+02	pay_col_01KSZ040JFEPH8MCEFB8KNTFRR	{}	2026-05-31 14:28:41.49+02	2026-05-31 14:28:41.649+02	\N
payses_01KSZ0VAYF75NZARP8Z2MSRSCG	usd	10100	{"value": "10100", "precision": 20}	pp_system_default	{}	{"customer": {"id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "email": "princelulinda32@gmail.com", "phone": "76777777", "metadata": null, "addresses": [{"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}], "last_name": "lulinda", "first_name": "prince", "company_name": null, "account_holders": [{"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}], "billing_address": {"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}}, "account_holder": {"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}}	authorized	2026-05-31 14:41:25.85+02	pay_col_01KSZ0VAW9SMZTJHEJ0T5M6QHJ	{}	2026-05-31 14:41:25.712+02	2026-05-31 14:41:25.856+02	\N
\.


--
-- Data for Name: price; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.price (id, title, price_set_id, currency_code, raw_amount, rules_count, created_at, updated_at, deleted_at, price_list_id, amount, min_quantity, max_quantity, raw_min_quantity, raw_max_quantity) FROM stdin;
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
\.


--
-- Data for Name: price_list; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.price_list (id, status, starts_at, ends_at, rules_count, title, description, type, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: price_list_rule; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.price_list_rule (id, price_list_id, created_at, updated_at, deleted_at, value, attribute) FROM stdin;
\.


--
-- Data for Name: price_preference; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.price_preference (id, attribute, value, is_tax_inclusive, created_at, updated_at, deleted_at) FROM stdin;
prpref_01KSCR9E49C3X2ZCWPA09DNWVB	currency_code	eur	f	2026-05-24 12:25:30.761+02	2026-05-24 12:25:30.761+02	\N
prpref_01KSCR9E5MEDG3F2MKA1K2DBNQ	currency_code	usd	f	2026-05-24 12:25:30.805+02	2026-05-24 12:25:30.805+02	\N
prpref_01KSCR9E6AE2GM6DZ1DE377XVA	region_id	reg_01KSCR9E5TH7739ZGVPZHV9YR7	f	2026-05-24 12:25:30.827+02	2026-05-24 12:25:30.827+02	\N
prpref_01KSR0QAQV5GNP1XRAK4YAAC1B	region_id	reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	f	2026-05-28 21:24:33.404+02	2026-05-28 21:24:33.404+02	\N
\.


--
-- Data for Name: price_rule; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
-- Data for Name: price_set; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.product (id, title, handle, subtitle, description, is_giftcard, status, thumbnail, weight, length, height, width, origin_country, hs_code, mid_code, material, collection_id, type_id, discountable, external_id, created_at, updated_at, deleted_at, metadata) FROM stdin;
prod_01KSCR9EA8QJ19M3XNSJCQTBKP	Medusa T-Shirt	t-shirt	\N	Reimagine the feeling of a classic T-shirt. With our cotton T-shirts, everyday essentials no longer have to be ordinary.	f	published	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-front.png	400	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-24 12:25:30.956+02	2026-05-24 12:25:30.956+02	\N	\N
prod_01KSCR9EA893MYMWYSTYVN97YD	Medusa Sweatshirt	sweatshirt	\N	Reimagine the feeling of a classic sweatshirt. With our cotton sweatshirt, everyday essentials no longer have to be ordinary.	f	published	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatshirt-vintage-front.png	400	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-24 12:25:30.956+02	2026-05-24 12:25:30.956+02	\N	\N
prod_01KSCR9EA81H268P4TP8HZKH76	Medusa Sweatpants	sweatpants	\N	Reimagine the feeling of classic sweatpants. With our cotton sweatpants, everyday essentials no longer have to be ordinary.	f	published	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatpants-gray-front.png	400	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N	\N
prod_01KSCR9EA8NPXFPM0RR3W38Q5X	Medusa Shorts	shorts	\N	Reimagine the feeling of classic shorts. With our cotton shorts, everyday essentials no longer have to be ordinary.	f	published	https://medusa-public-images.s3.eu-west-1.amazonaws.com/shorts-vintage-front.png	400	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-24 12:25:30.957+02	2026-05-24 12:25:30.957+02	\N	\N
prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	Ma saani	ma-saani	\N	Hello	f	published	http://localhost:9000/static/1779641482219-image.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-24 18:52:40.192+02	2026-05-24 18:52:40.192+02	\N	\N
prod_01KSH2A8YPQ2M4AN368YBJ9X3C	Sufuria	sufuria	\N	\N	f	published	http://localhost:9000/static/1779763040657-image.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-05-26 04:37:41.72+02	2026-05-26 04:37:41.72+02	\N	\N
prod_01KT156V00QYP2NS7HYG4BWMYG	Mapapa	mapapa	\N	\N	f	published	http://localhost:9000/static/1780302709862-image.jpg	2.5	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2026-06-01 10:36:05.762+02	2026-06-01 10:36:05.762+02	\N	\N
\.


--
-- Data for Name: product_category; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.product_category (id, name, description, handle, mpath, is_active, is_internal, rank, parent_category_id, created_at, updated_at, deleted_at, metadata) FROM stdin;
pcat_01KSCR9E9ZVXTPG1E8VDG33A00	Shirts		shirts	pcat_01KSCR9E9ZVXTPG1E8VDG33A00	t	f	0	\N	2026-05-24 12:25:30.944+02	2026-05-24 12:25:30.944+02	\N	\N
pcat_01KSCR9EA00PCV8J1G7TVW9RZZ	Sweatshirts		sweatshirts	pcat_01KSCR9EA00PCV8J1G7TVW9RZZ	t	f	1	\N	2026-05-24 12:25:30.944+02	2026-05-24 12:25:30.944+02	\N	\N
pcat_01KSCR9EA08Z6GF51A4AFAJZHD	Pants		pants	pcat_01KSCR9EA08Z6GF51A4AFAJZHD	t	f	2	\N	2026-05-24 12:25:30.944+02	2026-05-24 12:25:30.944+02	\N	\N
pcat_01KSCR9EA04Q9Y9507EGNTRQXD	Merch		merch	pcat_01KSCR9EA04Q9Y9507EGNTRQXD	t	f	3	\N	2026-05-24 12:25:30.944+02	2026-05-24 12:25:30.944+02	\N	\N
pcat_01KT14GCRSDYWE182SD6AFW2BB	Soulier		soulier	pcat_01KT14GCRSDYWE182SD6AFW2BB	t	f	4	\N	2026-06-01 10:23:50.297+02	2026-06-01 10:23:50.297+02	\N	\N
\.


--
-- Data for Name: product_category_product; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.product_category_product (product_id, product_category_id) FROM stdin;
prod_01KSCR9EA8QJ19M3XNSJCQTBKP	pcat_01KSCR9E9ZVXTPG1E8VDG33A00
prod_01KSCR9EA893MYMWYSTYVN97YD	pcat_01KSCR9EA00PCV8J1G7TVW9RZZ
prod_01KSCR9EA81H268P4TP8HZKH76	pcat_01KSCR9EA08Z6GF51A4AFAJZHD
prod_01KSCR9EA8NPXFPM0RR3W38Q5X	pcat_01KSCR9EA04Q9Y9507EGNTRQXD
\.


--
-- Data for Name: product_collection; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.product_collection (id, title, handle, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: product_option; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: product_option_value; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: product_sales_channel; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.product_sales_channel (product_id, sales_channel_id, id, created_at, updated_at, deleted_at) FROM stdin;
prod_01KSCR9EA8QJ19M3XNSJCQTBKP	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KSCR9EAR02GTFZ02KWZ9QCJR	2026-05-24 12:25:30.967909+02	2026-05-24 12:25:30.967909+02	\N
prod_01KSCR9EA893MYMWYSTYVN97YD	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KSCR9EAR8KH3MQNXB4VKJKDJ	2026-05-24 12:25:30.967909+02	2026-05-24 12:25:30.967909+02	\N
prod_01KSCR9EA81H268P4TP8HZKH76	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KSCR9EAR1ARFZ79S0J2X7HFQ	2026-05-24 12:25:30.967909+02	2026-05-24 12:25:30.967909+02	\N
prod_01KSCR9EA8NPXFPM0RR3W38Q5X	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KSCR9EARMF1V15GEBDW9D173	2026-05-24 12:25:30.967909+02	2026-05-24 12:25:30.967909+02	\N
prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KSDEEB4CJ7WRJ8BMGXQHTRGX	2026-05-24 18:52:40.203459+02	2026-05-24 18:52:40.203459+02	\N
prod_01KSH2A8YPQ2M4AN368YBJ9X3C	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KSH2A8Z43T31YE7277VD8515	2026-05-26 04:37:41.732177+02	2026-05-26 04:37:41.732177+02	\N
prod_01KT156V00QYP2NS7HYG4BWMYG	sc_01KSCR9E3HDNX82KGM4FXZDGP1	prodsc_01KT156V0MRQNVC94NED1EF665	2026-06-01 10:36:05.777638+02	2026-06-01 10:36:05.777638+02	\N
\.


--
-- Data for Name: product_shipping_profile; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.product_shipping_profile (product_id, shipping_profile_id, id, created_at, updated_at, deleted_at) FROM stdin;
prod_01KSCR9EA8QJ19M3XNSJCQTBKP	sp_01KSCR9E7ATTZKDD71J1GAA2V8	prodsp_01KSCR9EAYT0VCPRCQK2J2GSK8	2026-05-24 12:25:30.974151+02	2026-05-24 12:25:30.974151+02	\N
prod_01KSCR9EA893MYMWYSTYVN97YD	sp_01KSCR9E7ATTZKDD71J1GAA2V8	prodsp_01KSCR9EAYHGXZ7WVRZ49EKWQN	2026-05-24 12:25:30.974151+02	2026-05-24 12:25:30.974151+02	\N
prod_01KSCR9EA81H268P4TP8HZKH76	sp_01KSCR9E7ATTZKDD71J1GAA2V8	prodsp_01KSCR9EAYCRT1754GN62BTN0H	2026-05-24 12:25:30.974151+02	2026-05-24 12:25:30.974151+02	\N
prod_01KSCR9EA8NPXFPM0RR3W38Q5X	sp_01KSCR9E7ATTZKDD71J1GAA2V8	prodsp_01KSCR9EAYTVNBFJGB6C954791	2026-05-24 12:25:30.974151+02	2026-05-24 12:25:30.974151+02	\N
prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	sp_01KSCR51Y68N200HV70RYQZGR2	prodsp_01KSDEEB4K7Q1F1Y1BG1SMY6NS	2026-05-24 18:52:40.211351+02	2026-05-24 18:52:40.211351+02	\N
prod_01KSH2A8YPQ2M4AN368YBJ9X3C	sp_01KSCR51Y68N200HV70RYQZGR2	prodsp_01KSH2A8ZJYCVPH6P5Q3J4T3ZS	2026-05-26 04:37:41.746458+02	2026-05-26 04:37:41.746458+02	\N
prod_01KT156V00QYP2NS7HYG4BWMYG	sp_01KSCR51Y68N200HV70RYQZGR2	prodsp_01KT156V11XBSMVW9HBNCS31P6	2026-06-01 10:36:05.793333+02	2026-06-01 10:36:05.793333+02	\N
\.


--
-- Data for Name: product_tag; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.product_tag (id, value, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: product_tags; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.product_tags (product_id, product_tag_id) FROM stdin;
\.


--
-- Data for Name: product_type; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.product_type (id, value, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: product_variant; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: product_variant_inventory_item; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: product_variant_option; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: product_variant_price_set; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: product_variant_product_image; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.product_variant_product_image (id, variant_id, image_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: promotion; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.promotion (id, code, campaign_id, is_automatic, type, created_at, updated_at, deleted_at, status, is_tax_inclusive, "limit", used, metadata) FROM stdin;
promo_01KSFTYA07BW0AWQY1MGK5YPZ2	JJJJJJJK	\N	f	standard	2026-05-25 17:09:35.116+02	2026-05-25 17:25:35.113+02	2026-05-25 17:25:35.11+02	draft	f	\N	0	\N
promo_01KSSPF5WN97JJ7DAEWAWW9TQJ	YGO	\N	f	standard	2026-05-29 13:03:49.398+02	2026-05-29 13:03:49.398+02	\N	draft	f	\N	0	\N
\.


--
-- Data for Name: promotion_application_method; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.promotion_application_method (id, value, raw_value, max_quantity, apply_to_quantity, buy_rules_min_quantity, type, target_type, allocation, promotion_id, created_at, updated_at, deleted_at, currency_code) FROM stdin;
proappmet_01KSFTYA0A9HYX8WN5FXFPE6VX	20	{"value": "20", "precision": 20}	\N	\N	\N	percentage	items	across	promo_01KSFTYA07BW0AWQY1MGK5YPZ2	2026-05-25 17:09:35.115+02	2026-05-25 17:09:35.115+02	\N	\N
proappmet_01KSSPF5WPNHGDFXSEG1ATNVT6	20	{"value": "20", "precision": 20}	\N	\N	\N	percentage	items	across	promo_01KSSPF5WN97JJ7DAEWAWW9TQJ	2026-05-29 13:03:49.398+02	2026-05-29 13:03:49.398+02	\N	\N
\.


--
-- Data for Name: promotion_campaign; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.promotion_campaign (id, name, description, campaign_identifier, starts_at, ends_at, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: promotion_campaign_budget; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.promotion_campaign_budget (id, type, campaign_id, "limit", raw_limit, used, raw_used, created_at, updated_at, deleted_at, currency_code, attribute) FROM stdin;
\.


--
-- Data for Name: promotion_campaign_budget_usage; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.promotion_campaign_budget_usage (id, attribute_value, used, budget_id, raw_used, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: promotion_promotion_rule; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.promotion_promotion_rule (promotion_id, promotion_rule_id) FROM stdin;
\.


--
-- Data for Name: promotion_rule; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.promotion_rule (id, description, attribute, operator, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: promotion_rule_value; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.promotion_rule_value (id, promotion_rule_id, value, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: provider_identity; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: publishable_api_key_sales_channel; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.publishable_api_key_sales_channel (publishable_key_id, sales_channel_id, id, created_at, updated_at, deleted_at) FROM stdin;
apk_01KSCR9E4FPV3BZ6DTK9AQ9BCY	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pksc_01KSCR9E4RXPEG72XME0C41ENS	2026-05-24 12:25:30.776504+02	2026-05-24 12:25:30.776504+02	\N
apk_01KSCR9E9G4ZV5ENRXW1WS8XVC	sc_01KSCR9E3HDNX82KGM4FXZDGP1	pksc_01KSCR9E9QTMRMEBW2MWYB8HZ8	2026-05-24 12:25:30.934812+02	2026-05-24 12:25:30.934812+02	\N
\.


--
-- Data for Name: push_token; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: refund; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.refund (id, amount, raw_amount, payment_id, created_at, updated_at, deleted_at, created_by, metadata, refund_reason_id, note) FROM stdin;
\.


--
-- Data for Name: refund_reason; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.refund_reason (id, label, description, metadata, created_at, updated_at, deleted_at, code) FROM stdin;
refr_01KSCR4YZ4B75HDYM01KFGAFV6	Shipping Issue	Refund due to lost, delayed, or misdelivered shipment	\N	2026-05-24 12:23:04.119432+02	2026-05-24 12:23:04.119432+02	\N	shipping_issue
refr_01KSCR4YZ41X6RG8T6JTBJKNDE	Customer Care Adjustment	Refund given as goodwill or compensation for inconvenience	\N	2026-05-24 12:23:04.119432+02	2026-05-24 12:23:04.119432+02	\N	customer_care_adjustment
refr_01KSCR4YZ45HPY825GEPX212WG	Pricing Error	Refund to correct an overcharge, missing discount, or incorrect price	\N	2026-05-24 12:23:04.119432+02	2026-05-24 12:23:04.119432+02	\N	pricing_error
\.


--
-- Data for Name: region; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.region (id, name, currency_code, metadata, created_at, updated_at, deleted_at, automatic_taxes) FROM stdin;
reg_01KSCR9E5TH7739ZGVPZHV9YR7	Europe	eur	\N	2026-05-24 12:25:30.814+02	2026-05-28 21:23:51.082+02	2026-05-28 21:23:51.08+02	t
reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	East	usd	\N	2026-05-28 21:24:33.371+02	2026-05-28 21:24:33.371+02	\N	f
\.


--
-- Data for Name: region_country; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
-- Data for Name: region_payment_provider; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.region_payment_provider (region_id, payment_provider_id, id, created_at, updated_at, deleted_at) FROM stdin;
reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	pp_system_default	regpp_01KT721A17TV4PS1TGR8VBH790	2026-06-03 17:35:08.115828+02	2026-06-03 17:35:08.115828+02	\N
reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	pp_stripe_stripe	regpp_01KT721A1CBCVNMSG9M60G5YDE	2026-06-03 17:35:08.126731+02	2026-06-03 17:35:08.126731+02	\N
reg_01KSR0QAP4C6SG0JX6SG5ZK6BP	pp_kashflow_kashflow	regpp_01KT721A1G5XVKD2P1WAB4MNZ0	2026-06-03 17:35:08.129811+02	2026-06-03 17:35:08.129811+02	\N
\.


--
-- Data for Name: reservation_item; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
\.


--
-- Data for Name: return; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.return (id, order_id, claim_id, exchange_id, order_version, display_id, status, no_notification, refund_amount, raw_refund_amount, metadata, created_at, updated_at, deleted_at, received_at, canceled_at, location_id, requested_at, created_by) FROM stdin;
\.


--
-- Data for Name: return_fulfillment; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.return_fulfillment (return_id, fulfillment_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: return_item; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.return_item (id, return_id, reason_id, item_id, quantity, raw_quantity, received_quantity, raw_received_quantity, note, metadata, created_at, updated_at, deleted_at, damaged_quantity, raw_damaged_quantity) FROM stdin;
\.


--
-- Data for Name: return_reason; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.return_reason (id, value, label, description, metadata, parent_return_reason_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: review; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.review (id, product_id, customer_id, rating, content, created_at, updated_at, deleted_at) FROM stdin;
01KTEDDA6QZ1PC9D4NF4H10JMD	prod_01KSDEEB3Y6W05F6K2ZV4GC0BM	cus_01KSR173ECD4A2AJF6H3R1H2J8	3	Bonjour	2026-06-06 14:09:34.167+02	2026-06-06 14:09:34.167+02	\N
\.


--
-- Data for Name: sales_channel; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.sales_channel (id, name, description, is_disabled, metadata, created_at, updated_at, deleted_at) FROM stdin;
sc_01KSCR9E3HDNX82KGM4FXZDGP1	Default Sales Channel	Created by Medusa	f	\N	2026-05-24 12:25:30.737+02	2026-05-24 12:25:30.737+02	\N
\.


--
-- Data for Name: sales_channel_stock_location; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.sales_channel_stock_location (sales_channel_id, stock_location_id, id, created_at, updated_at, deleted_at) FROM stdin;
sc_01KSCR9E3HDNX82KGM4FXZDGP1	sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	scloc_01KSCR9E9B568Q1S4H3HZENDEH	2026-05-24 12:25:30.923577+02	2026-05-30 15:30:55.174+02	2026-05-30 15:30:55.173+02
sc_01KSCR9E3HDNX82KGM4FXZDGP1	sloc_01KSF7CHXY413KMNRYZAE8PT2S	scloc_01KSWK0WJ667ZS0MTZZ3K3KBZZ	2026-05-30 19:32:31.985386+02	2026-05-30 19:32:31.985386+02	\N
\.


--
-- Data for Name: script_migrations; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.script_migrations (id, script_name, created_at, finished_at) FROM stdin;
1	migrate-product-shipping-profile.js	2026-05-24 12:23:07.188232+02	2026-05-24 12:23:07.210974+02
2	migrate-tax-region-provider.js	2026-05-24 12:23:07.212871+02	2026-05-24 12:23:07.217854+02
\.


--
-- Data for Name: service_zone; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.service_zone (id, name, metadata, fulfillment_set_id, created_at, updated_at, deleted_at) FROM stdin;
serzo_01KSR2WQXBTFJMZ166JTCS1TZD	East	\N	fuset_01KSR2W2CKBZ3D4B3MB4Y2606S	2026-05-28 22:02:27.883+02	2026-05-28 22:02:27.883+02	\N
serzo_01KSCR9E7DM0H9XA9Y3A0H2YXP	Europe	\N	fuset_01KSCR9E7DBG6TWATM3CH2T54A	2026-05-24 12:25:30.861+02	2026-05-30 15:30:55.194+02	2026-05-30 15:30:55.183+02
serzo_01KSWJYMRZEWVVA94TM05N3RSQ	Eas	\N	fuset_01KSWJXMT5RA51MF8N6AK4SGNJ	2026-05-30 16:00:05.151+02	2026-05-30 16:00:05.151+02	\N
\.


--
-- Data for Name: shipping_option; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
-- Data for Name: shipping_option_price_set; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
-- Data for Name: shipping_option_rule; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
-- Data for Name: shipping_option_type; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.shipping_option_type (id, label, description, code, created_at, updated_at, deleted_at) FROM stdin;
sotype_01KSCR9E89781PFZZ2QE944HDA	Standard	Ship in 2-3 days.	standard	2026-05-24 12:25:30.891+02	2026-05-24 12:25:30.891+02	\N
sotype_01KSCR9E8AH9JNXPKP0QXCPGRT	Express	Ship in 24 hours.	express	2026-05-24 12:25:30.891+02	2026-05-24 12:25:30.891+02	\N
sotype_01KSR239149JMBYDWQS4JS9SZW	AVIo	Withdrawal request of 136.5 USDT on BEP20 to 0xe036498A99DE89E4b9d58AB8Dd5E5521a85E548E	avio	2026-05-28 21:48:33.444+02	2026-05-28 21:48:33.444+02	\N
\.


--
-- Data for Name: shipping_profile; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.shipping_profile (id, name, type, metadata, created_at, updated_at, deleted_at) FROM stdin;
sp_01KSCR51Y68N200HV70RYQZGR2	Default Shipping Profile	default	\N	2026-05-24 12:23:07.206+02	2026-05-24 12:23:07.207+02	\N
sp_01KSCR9E7ATTZKDD71J1GAA2V8	Default	default	\N	2026-05-24 12:25:30.858+02	2026-05-24 12:25:30.858+02	\N
\.


--
-- Data for Name: short_video; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
01KSRB09F12K4PY852ZDN2R3MQ	01KSCSTSP7N25SPSF2H5AK45FY	Glasses		http://localhost:9000/static/1780007052610-video_1780007044686.mp4	\N	\N	mode	published	1	0	5	41	[]	2026-05-29 00:24:12.769+02	2026-06-07 15:09:47.251+02	\N	http://localhost:9000/static/1780007052610-video_1780007044686.mp4	f
01KT1579P8KXJYXZR33E8D7H5A	01KSDE9JVTNAXE0NF67DNVEWBS	Vidéo Mapapa		http://localhost:9000/static/1780302980618-video_1780302965198.mp4	\N	\N	produit	published	0	0	0	27	["prod_01KT156V00QYP2NS7HYG4BWMYG"]	2026-06-01 10:36:20.809+02	2026-06-07 15:09:38.427+02	\N	http://localhost:9000/static/1780302980618-video_1780302965198.mp4	f
01KSRBXKRZRKXFAZK6VWV2WNBW	01KSCSTSP7N25SPSF2H5AK45FY	Saani		http://localhost:9000/static/1780008013464-video_1780008011454.mp4	\N	\N	mode	published	1	3	0	80	["prod_01KSH2A8YPQ2M4AN368YBJ9X3C"]	2026-05-29 00:40:13.6+02	2026-06-07 15:09:41.995+02	\N	http://localhost:9000/static/1780008013464-video_1780008011454.mp4	f
01KSRBWX4WCXHWPJ5AM9C54AS2	01KSCSTSP7N25SPSF2H5AK45FY	Hot pot		http://localhost:9000/static/1780007990218-video_1780007983538.mp4	\N	\N	mode	published	2	0	0	60	[]	2026-05-29 00:39:50.428+02	2026-06-07 15:09:45.607+02	\N	http://localhost:9000/static/1780007990218-video_1780007983538.mp4	f
\.


--
-- Data for Name: stock_location; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.stock_location (id, created_at, updated_at, deleted_at, name, address_id, metadata) FROM stdin;
sloc_01KSF7CHXY413KMNRYZAE8PT2S	2026-05-25 11:27:50.463+02	2026-05-25 11:27:50.463+02	\N	Bujumbura	laddr_01KSF7CHXYKEWR6G52MKEQ0EGY	\N
sloc_01KSCR9E6Z1Y3WGDV7A4G289RG	2026-05-24 12:25:30.847+02	2026-05-30 15:30:55.135+02	2026-05-30 15:30:55.132+02	European Warehouse	laddr_01KSCR9E6YNQMYK9WRDF27Q1B5	\N
\.


--
-- Data for Name: stock_location_address; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.stock_location_address (id, created_at, updated_at, deleted_at, address_1, address_2, company, city, country_code, phone, province, postal_code, metadata) FROM stdin;
laddr_01KSF7CHXYKEWR6G52MKEQ0EGY	2026-05-25 11:27:50.462+02	2026-05-25 11:27:50.462+02	\N	10 avenue	\N	\N	Bujumbura	bu	\N	\N	\N	\N
laddr_01KSCR9E6YNQMYK9WRDF27Q1B5	2026-05-24 12:25:30.847+02	2026-05-30 15:30:55.153+02	2026-05-30 15:30:55.132+02		\N	\N	Copenhagen	DK	\N	\N	\N	\N
\.


--
-- Data for Name: store; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.store (id, name, default_sales_channel_id, default_region_id, default_location_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
store_01KSCR9E3Z2Z3635HXYG0Y2KH4	Medusa Store	sc_01KSCR9E3HDNX82KGM4FXZDGP1	\N	\N	\N	2026-05-24 12:25:30.750211+02	2026-05-24 12:25:30.750211+02	\N
\.


--
-- Data for Name: store_currency; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.store_currency (id, currency_code, is_default, store_id, created_at, updated_at, deleted_at) FROM stdin;
stocur_01KSCR9E5DQFHZ22EC5V3EBZGH	eur	t	store_01KSCR9E3Z2Z3635HXYG0Y2KH4	2026-05-24 12:25:30.794998+02	2026-05-24 12:25:30.794998+02	\N
stocur_01KSCR9E5DA5JBB40T4E96F1K4	usd	f	store_01KSCR9E3Z2Z3635HXYG0Y2KH4	2026-05-24 12:25:30.794998+02	2026-05-24 12:25:30.794998+02	\N
\.


--
-- Data for Name: store_locale; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.store_locale (id, locale_code, store_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: tax_provider; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.tax_provider (id, is_enabled, created_at, updated_at, deleted_at) FROM stdin;
tp_system	t	2026-05-24 12:23:06.722+02	2026-05-24 12:23:06.722+02	\N
\.


--
-- Data for Name: tax_rate; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.tax_rate (id, rate, code, name, is_default, is_combinable, tax_region_id, metadata, created_at, updated_at, created_by, deleted_at) FROM stdin;
\.


--
-- Data for Name: tax_rate_rule; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.tax_rate_rule (id, tax_rate_id, reference_id, reference, metadata, created_at, updated_at, created_by, deleted_at) FROM stdin;
\.


--
-- Data for Name: tax_region; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
-- Data for Name: translation; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.translation (id, reference_id, reference, locale_code, translations, created_at, updated_at, deleted_at, translated_field_count) FROM stdin;
\.


--
-- Data for Name: translation_settings; Type: TABLE DATA; Schema: public; Owner: princelulinda
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
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public."user" (id, first_name, last_name, email, avatar_url, metadata, created_at, updated_at, deleted_at) FROM stdin;
user_01KSCRW542GHYQFHM9FB3QZM2J	\N	\N	princelulinda@gmail.com	\N	\N	2026-05-24 12:35:44.13+02	2026-05-24 12:35:44.13+02	\N
\.


--
-- Data for Name: user_preference; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.user_preference (id, user_id, key, value, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: user_rbac_role; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.user_rbac_role (user_id, rbac_role_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: vendor; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.vendor (id, handle, name, logo, created_at, updated_at, deleted_at, cover_image, description, phone, email, website, country, city, address, founded_year, business_type, main_products, employee_count, social_links, is_verified, response_rate, response_time, balance) FROM stdin;
01KSCS6FH5H9J6QY6ZPJ0110W5	bbbbb	Myself 	\N	2026-05-24 12:41:22.47+02	2026-05-24 12:41:22.47+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	0
01KSCSTSP7N25SPSF2H5AK45FY	uuuu	Myself 	\N	2026-05-24 12:52:28.231+02	2026-05-24 12:52:28.231+02	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	0
01KSDE9JVTNAXE0NF67DNVEWBS	yyyyy	My boutique 	http://localhost:9000/static/1779642732390-image.jpg	2026-05-24 18:50:04.282+02	2026-05-25 11:51:32.397+02	\N	\N	Hello	\N	\N	http///sannia.bi	\N	\N	\N	\N	trader	\N	\N	{"instagram": "https://Instagram.com"}	f	\N	\N	0
\.


--
-- Data for Name: vendor_admin; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.vendor_admin (id, first_name, last_name, email, vendor_id, created_at, updated_at, deleted_at) FROM stdin;
01KSCS6FHM3T088JTDVNHWEAP0	Prince 	Lulinda 	princelulinda12@gmail.com	01KSCS6FH5H9J6QY6ZPJ0110W5	2026-05-24 12:41:22.484+02	2026-05-24 12:41:22.484+02	\N
01KSCSTSPDSEAN744XV198F4RD	Prince 	Crespo 	princelulinda1@gmail.com	01KSCSTSP7N25SPSF2H5AK45FY	2026-05-24 12:52:28.237+02	2026-05-24 12:52:28.237+02	\N
01KSDE9JW0MFK1W1NWQ29QV25V	Prince 	Crespo	princelulinda122@gmail.com	01KSDE9JVTNAXE0NF67DNVEWBS	2026-05-24 18:50:04.288+02	2026-05-24 18:50:04.288+02	\N
\.


--
-- Data for Name: video_comment; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.video_comment (id, video_id, customer_id, content, created_at, updated_at, deleted_at, vendor_id, parent_id) FROM stdin;
01KSS5SWJBWC4WKWXK1HFC69SE	01KSRBXKRZRKXFAZK6VWV2WNBW	cus_01KSR173ECD4A2AJF6H3R1H2J8	Hello	2026-05-29 08:12:34.507+02	2026-05-29 08:12:34.507+02	\N	\N	\N
01KSS5T80VTNK54P0KQW8XK2P5	01KSRBXKRZRKXFAZK6VWV2WNBW	cus_01KSR173ECD4A2AJF6H3R1H2J8	No	2026-05-29 08:12:46.235+02	2026-05-29 08:12:46.235+02	\N	\N	01KSS5SWJBWC4WKWXK1HFC69SE
01KTFEDD0K51H11XGPH2FEQKC4	01KSRBXKRZRKXFAZK6VWV2WNBW	cus_01KSR173ECD4A2AJF6H3R1H2J8	Bonjour	2026-06-06 23:46:20.051+02	2026-06-06 23:46:20.051+02	\N	\N	\N
\.


--
-- Data for Name: video_like; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.video_like (id, video_id, customer_id, created_at, updated_at, deleted_at) FROM stdin;
01KSRBG4AQ57PQ8P23CB7ET543	01KSRB09F12K4PY852ZDN2R3MQ	cus_01KSR173ECD4A2AJF6H3R1H2J8	2026-05-29 00:32:51.8+02	2026-05-29 00:32:51.8+02	\N
01KSS37T1K3J0JQ9WXN9FYVXGE	01KSRBWX4WCXHWPJ5AM9C54AS2	cus_01KSR173ECD4A2AJF6H3R1H2J8	2026-05-29 07:27:44.947+02	2026-05-29 07:27:44.947+02	\N
01KSWSGDFEK3M02APSWPVJFNZ4	01KSRBWX4WCXHWPJ5AM9C54AS2	cus_01KSWS7V39C4SDB1YTY9K83SMS	2026-05-30 17:54:38.959+02	2026-05-30 17:54:38.959+02	\N
01KTFEH2ST5D3BF7YAKAD910JV	01KSRBXKRZRKXFAZK6VWV2WNBW	cus_01KSR173ECD4A2AJF6H3R1H2J8	2026-06-06 23:48:20.666+02	2026-06-06 23:48:20.666+02	\N
\.


--
-- Data for Name: video_save; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.video_save (id, video_id, customer_id, created_at, updated_at, deleted_at) FROM stdin;
01KSRC6GWAAT3Z0NRQB9V9EEBQ	01KSRBWX4WCXHWPJ5AM9C54AS2	cus_01KSR173ECD4A2AJF6H3R1H2J8	2026-05-29 00:45:05.547+02	2026-05-29 00:45:05.547+02	\N
01KSSQHWGE1Q4NHKCHGQ52YQ07	01KSRB09F12K4PY852ZDN2R3MQ	cus_01KSR173ECD4A2AJF6H3R1H2J8	2026-05-29 13:22:46.67+02	2026-05-29 13:22:46.67+02	\N
\.


--
-- Data for Name: view_configuration; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.view_configuration (id, entity, name, user_id, is_system_default, configuration, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: workflow_execution; Type: TABLE DATA; Schema: public; Owner: princelulinda
--

COPY public.workflow_execution (id, workflow_id, transaction_id, execution, context, state, created_at, updated_at, deleted_at, retention_time, run_id) FROM stdin;
wf_exec_01KTBF4WPZ863KYZ2G0Q3R96Z6	complete-cart	complete-cart-as-step-auto-01KTBF4WNWGWQVSQYE9DKKYN8J	{"_v": 0, "runId": "01KTBF4WP1NMKTT7VK9FVNBP90", "state": "reverted", "steps": {"_root": {"id": "_root", "next": ["_root.acquire-lock-step"]}, "_root.acquire-lock-step": {"_v": 0, "id": "_root.acquire-lock-step", "next": ["_root.acquire-lock-step.use-query-graph-step", "_root.acquire-lock-step.cart-query"], "uuid": "01KTBF3WDCCDYN6MPP7HP9HSDT", "depth": 1, "invoke": {"state": "skipped", "status": "ok"}, "attempts": 1, "failures": 0, "startedAt": 1780648932075, "compensate": {"state": "dormant", "status": "idle"}, "definition": {"uuid": "01KTBF3WDCCDYN6MPP7HP9HSDT", "store": false, "action": "acquire-lock-step", "noCompensation": false}, "stepFailed": false, "lastAttempt": 1780648932075, "saveResponse": true}, "_root.acquire-lock-step.cart-query": {"_v": 0, "id": "_root.acquire-lock-step.cart-query", "next": ["_root.acquire-lock-step.cart-query.validate-cart-payments"], "uuid": "01KTBF3WDD8ST043QSGYAM4B8Z", "depth": 2, "invoke": {"state": "done", "status": "ok"}, "attempts": 1, "failures": 0, "startedAt": 1780648932077, "compensate": {"state": "reverted", "status": "idle"}, "definition": {"uuid": "01KTBF3WDD8ST043QSGYAM4B8Z", "async": false, "store": false, "action": "cart-query", "noCompensation": true, "compensateAsync": false}, "stepFailed": true, "lastAttempt": 1780648932535, "saveResponse": true}, "_root.acquire-lock-step.use-query-graph-step": {"_v": 0, "id": "_root.acquire-lock-step.use-query-graph-step", "next": [], "uuid": "01KTBF3WDD7NWD2ZQC7BRZ4SNR", "depth": 2, "invoke": {"state": "done", "status": "ok"}, "attempts": 1, "failures": 0, "startedAt": 1780648932077, "compensate": {"state": "reverted", "status": "idle"}, "definition": {"uuid": "01KTBF3WDD7NWD2ZQC7BRZ4SNR", "store": false, "action": "use-query-graph-step", "noCompensation": true}, "stepFailed": true, "lastAttempt": 1780648932423, "saveResponse": true}, "_root.acquire-lock-step.cart-query.validate-cart-payments": {"_v": 0, "id": "_root.acquire-lock-step.cart-query.validate-cart-payments", "next": ["_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed"], "uuid": "01KTBF3WDDK4KG1EPF0RS844MZ", "depth": 3, "invoke": {"state": "done", "status": "ok"}, "attempts": 1, "failures": 0, "startedAt": 1780648932148, "compensate": {"state": "reverted", "status": "idle"}, "definition": {"uuid": "01KTBF3WDDK4KG1EPF0RS844MZ", "store": false, "action": "validate-cart-payments", "noCompensation": true}, "stepFailed": true, "lastAttempt": 1780648932534, "saveResponse": true}, "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed": {"_v": 0, "id": "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed", "next": ["_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate"], "uuid": "01KTBF3WDD7N2C0A3M56BX7N08", "depth": 4, "invoke": {"state": "done", "status": "ok"}, "attempts": 1, "failures": 0, "startedAt": 1780648932152, "compensate": {"state": "reverted", "status": "ok"}, "definition": {"uuid": "01KTBF3WDD7N2C0A3M56BX7N08", "store": false, "action": "compensate-payment-if-needed", "noCompensation": false}, "stepFailed": true, "lastAttempt": 1780648932524, "saveResponse": true}, "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate": {"_v": 0, "id": "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate", "next": ["_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query"], "uuid": "01KTBF3WDDCANCNZDWWMT9DK1Q", "depth": 5, "invoke": {"state": "done", "status": "ok"}, "attempts": 1, "failures": 0, "startedAt": 1780648932155, "compensate": {"state": "reverted", "status": "ok"}, "definition": {"uuid": "01KTBF3WDDCANCNZDWWMT9DK1Q", "store": false, "action": "validate", "noCompensation": false}, "stepFailed": true, "lastAttempt": 1780648932518, "saveResponse": true}, "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query": {"_v": 0, "id": "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query", "next": ["_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping"], "uuid": "01KTBF3WDE4GGBKH5CBD8C78TS", "depth": 6, "invoke": {"state": "done", "status": "ok"}, "attempts": 1, "failures": 0, "startedAt": 1780648932159, "compensate": {"state": "reverted", "status": "idle"}, "definition": {"uuid": "01KTBF3WDE4GGBKH5CBD8C78TS", "async": false, "store": false, "action": "shipping-options-query", "noCompensation": true, "compensateAsync": false}, "stepFailed": true, "lastAttempt": 1780648932517, "saveResponse": true}, "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping": {"_v": 0, "id": "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping", "next": ["_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders"], "uuid": "01KTBF3WDEND212CX09DJRB2DW", "depth": 7, "invoke": {"state": "done", "status": "ok"}, "attempts": 1, "failures": 0, "startedAt": 1780648932170, "compensate": {"state": "reverted", "status": "idle"}, "definition": {"uuid": "01KTBF3WDEND212CX09DJRB2DW", "store": false, "action": "validate-shipping", "noCompensation": true}, "stepFailed": true, "lastAttempt": 1780648932515, "saveResponse": true}, "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders": {"_v": 0, "id": "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders", "next": ["_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.create-remote-links", "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.update-carts", "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.reserve-inventory-step", "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.register-usage", "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.emit-event-step"], "uuid": "01KTBF3WDE4SKSACPHBAXZ763F", "depth": 8, "invoke": {"state": "done", "status": "ok"}, "attempts": 1, "failures": 0, "startedAt": 1780648932176, "compensate": {"state": "reverted", "status": "ok"}, "definition": {"uuid": "01KTBF3WDE4SKSACPHBAXZ763F", "store": false, "action": "create-orders", "noCompensation": false}, "stepFailed": true, "lastAttempt": 1780648932476, "saveResponse": true}, "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.update-carts": {"_v": 0, "id": "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.update-carts", "next": [], "uuid": "01KTBF3WDE7QC5EWFWBN4E9D45", "depth": 9, "invoke": {"state": "done", "status": "ok"}, "attempts": 1, "failures": 0, "startedAt": 1780648932291, "compensate": {"state": "reverted", "status": "ok"}, "definition": {"uuid": "01KTBF3WDE7QC5EWFWBN4E9D45", "store": false, "action": "update-carts", "noCompensation": false}, "stepFailed": true, "lastAttempt": 1780648932423, "saveResponse": true}, "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.register-usage": {"_v": 0, "id": "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.register-usage", "next": [], "uuid": "01KTBF3WDENDD976DF9DAYJ2KW", "depth": 9, "invoke": {"state": "done", "status": "ok"}, "attempts": 1, "failures": 0, "startedAt": 1780648932291, "compensate": {"state": "reverted", "status": "ok"}, "definition": {"uuid": "01KTBF3WDENDD976DF9DAYJ2KW", "store": false, "action": "register-usage", "noCompensation": false}, "stepFailed": true, "lastAttempt": 1780648932423, "saveResponse": true}, "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.emit-event-step": {"_v": 0, "id": "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.emit-event-step", "next": ["_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.emit-event-step.beforePaymentAuthorization"], "uuid": "01KTBF3WDEM6G5CP455JAA4SYB", "depth": 9, "invoke": {"state": "done", "status": "ok"}, "attempts": 1, "failures": 0, "startedAt": 1780648932291, "compensate": {"state": "reverted", "status": "ok"}, "definition": {"uuid": "01KTBF3WDEM6G5CP455JAA4SYB", "store": false, "action": "emit-event-step", "noCompensation": false}, "stepFailed": true, "lastAttempt": 1780648932473, "saveResponse": true}, "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.create-remote-links": {"_v": 0, "id": "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.create-remote-links", "next": [], "uuid": "01KTBF3WDES0F23BC1PZEZJ408", "depth": 9, "invoke": {"state": "done", "status": "ok"}, "attempts": 1, "failures": 0, "startedAt": 1780648932291, "compensate": {"state": "reverted", "status": "ok"}, "definition": {"uuid": "01KTBF3WDES0F23BC1PZEZJ408", "store": false, "action": "create-remote-links", "noCompensation": false}, "stepFailed": true, "lastAttempt": 1780648932423, "saveResponse": true}, "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.reserve-inventory-step": {"_v": 0, "id": "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.reserve-inventory-step", "next": [], "uuid": "01KTBF3WDEEZE8DK27AAEGEKCB", "depth": 9, "invoke": {"state": "done", "status": "ok"}, "attempts": 1, "failures": 0, "startedAt": 1780648932291, "compensate": {"state": "reverted", "status": "ok"}, "definition": {"uuid": "01KTBF3WDEEZE8DK27AAEGEKCB", "store": false, "action": "reserve-inventory-step", "noCompensation": false}, "stepFailed": true, "lastAttempt": 1780648932423, "saveResponse": true}, "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.emit-event-step.beforePaymentAuthorization": {"_v": 0, "id": "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.emit-event-step.beforePaymentAuthorization", "next": ["_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.emit-event-step.beforePaymentAuthorization.authorize-payment-session-step"], "uuid": "01KTBF3WDFYGME0WJ177WA55YM", "depth": 10, "invoke": {"state": "done", "status": "ok"}, "attempts": 1, "failures": 0, "startedAt": 1780648932368, "compensate": {"state": "reverted", "status": "ok"}, "definition": {"uuid": "01KTBF3WDFYGME0WJ177WA55YM", "store": false, "action": "beforePaymentAuthorization", "noCompensation": false}, "stepFailed": true, "lastAttempt": 1780648932470, "saveResponse": true}, "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.emit-event-step.beforePaymentAuthorization.authorize-payment-session-step": {"_v": 0, "id": "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.emit-event-step.beforePaymentAuthorization.authorize-payment-session-step", "next": ["_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.emit-event-step.beforePaymentAuthorization.authorize-payment-session-step.add-order-transaction"], "uuid": "01KTBF3WDF6F29M2X0F0PG7NJ3", "depth": 11, "invoke": {"state": "failed", "status": "permanent_failure"}, "attempts": 1, "failures": 0, "startedAt": 1780648932371, "compensate": {"state": "reverted", "status": "ok"}, "definition": {"uuid": "01KTBF3WDF6F29M2X0F0PG7NJ3", "store": false, "action": "authorize-payment-session-step", "noCompensation": false}, "stepFailed": true, "lastAttempt": 1780648932423, "saveResponse": true}, "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.emit-event-step.beforePaymentAuthorization.authorize-payment-session-step.add-order-transaction": {"_v": 0, "id": "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.emit-event-step.beforePaymentAuthorization.authorize-payment-session-step.add-order-transaction", "next": ["_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.emit-event-step.beforePaymentAuthorization.authorize-payment-session-step.add-order-transaction.orderCreated"], "uuid": "01KTBF3WDF7GK6XV01BQED8GT2", "depth": 12, "invoke": {"state": "not_started", "status": "idle"}, "attempts": 0, "failures": 0, "compensate": {"state": "dormant", "status": "idle"}, "definition": {"uuid": "01KTBF3WDF7GK6XV01BQED8GT2", "store": false, "action": "add-order-transaction", "noCompensation": false}, "stepFailed": false, "lastAttempt": null, "saveResponse": true}, "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.emit-event-step.beforePaymentAuthorization.authorize-payment-session-step.add-order-transaction.orderCreated": {"_v": 0, "id": "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.emit-event-step.beforePaymentAuthorization.authorize-payment-session-step.add-order-transaction.orderCreated", "next": ["_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.emit-event-step.beforePaymentAuthorization.authorize-payment-session-step.add-order-transaction.orderCreated.create-order"], "uuid": "01KTBF3WDFVN1G7VN2PS9KHNXH", "depth": 13, "invoke": {"state": "not_started", "status": "idle"}, "attempts": 0, "failures": 0, "compensate": {"state": "dormant", "status": "idle"}, "definition": {"uuid": "01KTBF3WDFVN1G7VN2PS9KHNXH", "store": false, "action": "orderCreated", "noCompensation": false}, "stepFailed": false, "lastAttempt": null, "saveResponse": true}, "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.emit-event-step.beforePaymentAuthorization.authorize-payment-session-step.add-order-transaction.orderCreated.create-order": {"_v": 0, "id": "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.emit-event-step.beforePaymentAuthorization.authorize-payment-session-step.add-order-transaction.orderCreated.create-order", "next": ["_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.emit-event-step.beforePaymentAuthorization.authorize-payment-session-step.add-order-transaction.orderCreated.create-order.release-lock-step"], "uuid": "01KTBF3WDF64M8XC3M9MD17R9M", "depth": 14, "invoke": {"state": "not_started", "status": "idle"}, "attempts": 0, "failures": 0, "compensate": {"state": "dormant", "status": "idle"}, "definition": {"uuid": "01KTBF3WDF64M8XC3M9MD17R9M", "store": false, "action": "create-order", "noCompensation": true}, "stepFailed": false, "lastAttempt": null, "saveResponse": true}, "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.emit-event-step.beforePaymentAuthorization.authorize-payment-session-step.add-order-transaction.orderCreated.create-order.release-lock-step": {"_v": 0, "id": "_root.acquire-lock-step.cart-query.validate-cart-payments.compensate-payment-if-needed.validate.shipping-options-query.validate-shipping.create-orders.emit-event-step.beforePaymentAuthorization.authorize-payment-session-step.add-order-transaction.orderCreated.create-order.release-lock-step", "next": [], "uuid": "01KTBF3WDF5GPD39G8FNFYZR98", "depth": 15, "invoke": {"state": "not_started", "status": "idle"}, "attempts": 0, "failures": 0, "compensate": {"state": "dormant", "status": "idle"}, "definition": {"uuid": "01KTBF3WDF5GPD39G8FNFYZR98", "store": false, "action": "release-lock-step", "noCompensation": true}, "stepFailed": false, "lastAttempt": null, "saveResponse": true}}, "modelId": "complete-cart", "options": {"name": "complete-cart", "store": true, "idempotent": false, "retentionTime": 259200}, "metadata": {"sourcePath": "/home/princelulinda/Documents/projects/eastmarket_backend/node_modules/@medusajs/core-flows/dist/cart/workflows/complete-cart.js", "eventGroupId": "01KTBF4WNWGWQVSQYE9DKKYN8J", "preventReleaseEvents": true, "parentStepIdempotencyKey": "create-vendor-order:auto-01KTBF4WNWGWQVSQYE9DKKYN8J:complete-cart-as-step:invoke"}, "startedAt": 1780648932074, "definition": {"next": [{"uuid": "01KTBF3WDD7NWD2ZQC7BRZ4SNR", "action": "use-query-graph-step", "noCompensation": true}, {"next": {"next": {"next": {"next": {"next": {"next": {"next": [{"uuid": "01KTBF3WDES0F23BC1PZEZJ408", "action": "create-remote-links", "noCompensation": false}, {"uuid": "01KTBF3WDE7QC5EWFWBN4E9D45", "action": "update-carts", "noCompensation": false}, {"uuid": "01KTBF3WDEEZE8DK27AAEGEKCB", "action": "reserve-inventory-step", "noCompensation": false}, {"uuid": "01KTBF3WDENDD976DF9DAYJ2KW", "action": "register-usage", "noCompensation": false}, {"next": {"next": {"next": {"next": {"next": {"next": {"uuid": "01KTBF3WDF5GPD39G8FNFYZR98", "action": "release-lock-step", "noCompensation": true}, "uuid": "01KTBF3WDF64M8XC3M9MD17R9M", "action": "create-order", "noCompensation": true}, "uuid": "01KTBF3WDFVN1G7VN2PS9KHNXH", "action": "orderCreated", "noCompensation": false}, "uuid": "01KTBF3WDF7GK6XV01BQED8GT2", "action": "add-order-transaction", "noCompensation": false}, "uuid": "01KTBF3WDF6F29M2X0F0PG7NJ3", "action": "authorize-payment-session-step", "noCompensation": false}, "uuid": "01KTBF3WDFYGME0WJ177WA55YM", "action": "beforePaymentAuthorization", "noCompensation": false}, "uuid": "01KTBF3WDEM6G5CP455JAA4SYB", "action": "emit-event-step", "noCompensation": false}], "uuid": "01KTBF3WDE4SKSACPHBAXZ763F", "action": "create-orders", "noCompensation": false}, "uuid": "01KTBF3WDEND212CX09DJRB2DW", "action": "validate-shipping", "noCompensation": true}, "uuid": "01KTBF3WDE4GGBKH5CBD8C78TS", "async": false, "action": "shipping-options-query", "noCompensation": true, "compensateAsync": false}, "uuid": "01KTBF3WDDCANCNZDWWMT9DK1Q", "action": "validate", "noCompensation": false}, "uuid": "01KTBF3WDD7N2C0A3M56BX7N08", "action": "compensate-payment-if-needed", "noCompensation": false}, "uuid": "01KTBF3WDDK4KG1EPF0RS844MZ", "action": "validate-cart-payments", "noCompensation": true}, "uuid": "01KTBF3WDD8ST043QSGYAM4B8Z", "async": false, "action": "cart-query", "noCompensation": true, "compensateAsync": false}], "uuid": "01KTBF3WDCCDYN6MPP7HP9HSDT", "action": "acquire-lock-step", "noCompensation": false}, "timedOutAt": null, "hasAsyncSteps": false, "transactionId": "complete-cart-as-step-auto-01KTBF4WNWGWQVSQYE9DKKYN8J", "hasFailedSteps": false, "hasSkippedSteps": true, "hasWaitingSteps": false, "hasRevertedSteps": true, "hasSkippedOnFailureSteps": false}	{"data": {"invoke": {"validate": {"__type": "Symbol(WorkflowWorkflowData)", "output": {"__type": "Symbol(WorkflowStepResponse)"}}, "cart-query": {"__type": "Symbol(WorkflowWorkflowData)", "output": {"__type": "Symbol(WorkflowStepResponse)", "output": {"data": {"id": "cart_01KT1VZFSW5FDQCERA8BX242EF", "email": "princelulinda32@gmail.com", "items": [{"id": "cali_01KTA7Z2PX415ZRJRPT2NWMFDT", "title": "Ma saani", "total": 10000, "cart_id": "cart_01KT1VZFSW5FDQCERA8BX242EF", "variant": {"id": "variant_01KSDEEB4X5XQS5EZAMWG8KH96", "product": {"id": "prod_01KSDEEB3Y6W05F6K2ZV4GC0BM", "is_giftcard": false, "shipping_profile": {"id": "sp_01KSCR51Y68N200HV70RYQZGR2"}}, "product_id": "prod_01KSDEEB3Y6W05F6K2ZV4GC0BM", "allow_backorder": false, "inventory_items": [{"inventory": {"id": "iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX", "location_levels": [{"location_id": "sloc_01KSF7CHXY413KMNRYZAE8PT2S", "stock_locations": [{"id": "sloc_01KSF7CHXY413KMNRYZAE8PT2S", "name": "Bujumbura", "sales_channels": [{"id": "sc_01KSCR9E3HDNX82KGM4FXZDGP1", "name": "Default Sales Channel"}]}], "stocked_quantity": 95, "reserved_quantity": 7, "raw_stocked_quantity": {"value": "95", "precision": 20}, "raw_reserved_quantity": {"value": "7", "precision": 20}}], "requires_shipping": true}, "variant_id": "variant_01KSDEEB4X5XQS5EZAMWG8KH96", "inventory_item_id": "iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX", "required_quantity": 1}], "manage_inventory": true}, "metadata": {}, "quantity": 1, "subtitle": "Rouge", "subtotal": 10000, "raw_total": {"value": "10000", "precision": 20}, "tax_lines": [], "tax_total": 0, "thumbnail": "http://localhost:9000/static/1779641482219-image.jpg", "created_at": "2026-06-04T21:17:27.133Z", "deleted_at": null, "product_id": "prod_01KSDEEB3Y6W05F6K2ZV4GC0BM", "unit_price": 10000, "updated_at": "2026-06-04T21:17:27.133Z", "variant_id": "variant_01KSDEEB4X5XQS5EZAMWG8KH96", "adjustments": [], "is_giftcard": false, "variant_sku": null, "product_type": null, "raw_subtotal": {"value": "10000", "precision": 20}, "product_title": "Ma saani", "raw_tax_total": {"value": "0", "precision": 20}, "variant_title": "Rouge", "discount_total": 0, "original_total": 10000, "product_handle": "ma-saani", "raw_unit_price": {"value": "10000", "precision": 20}, "is_custom_price": false, "is_discountable": true, "product_type_id": null, "variant_barcode": null, "is_tax_inclusive": false, "product_subtitle": null, "discount_subtotal": 0, "original_subtotal": 10000, "requires_shipping": true, "discount_tax_total": 0, "original_tax_total": 0, "product_collection": null, "raw_discount_total": {"value": "0", "precision": 20}, "raw_original_total": {"value": "10000", "precision": 20}, "product_description": "Hello", "compare_at_unit_price": null, "raw_discount_subtotal": {"value": "0", "precision": 20}, "raw_original_subtotal": {"value": "10000", "precision": 20}, "variant_option_values": null, "raw_discount_tax_total": {"value": "0", "precision": 20}, "raw_original_tax_total": {"value": "0", "precision": 20}, "raw_compare_at_unit_price": null}], "total": 10010, "locale": null, "region": {"id": "reg_01KSR0QAP4C6SG0JX6SG5ZK6BP", "name": "East", "metadata": null, "created_at": "2026-05-28T19:24:33.371Z", "deleted_at": null, "updated_at": "2026-05-28T19:24:33.371Z", "currency_code": "usd", "automatic_taxes": false}, "customer": {"id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "email": "princelulinda32@gmail.com", "phone": "76777777", "metadata": null, "last_name": "lulinda", "created_at": "2026-05-28T19:33:10.221Z", "created_by": null, "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:33:10.221Z", "has_account": true, "company_name": null}, "metadata": null, "subtotal": 10010, "raw_total": {"value": "10010", "precision": 20}, "region_id": "reg_01KSR0QAP4C6SG0JX6SG5ZK6BP", "tax_total": 0, "created_at": "2026-06-01T15:14:02.176Z", "item_total": 10000, "promotions": [], "updated_at": "2026-06-05T08:27:25.250Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "completed_at": null, "credit_lines": [], "raw_subtotal": {"value": "10010", "precision": 20}, "currency_code": "usd", "item_subtotal": 10000, "raw_tax_total": {"value": "0", "precision": 20}, "discount_total": 0, "item_tax_total": 0, "original_total": 10010, "raw_item_total": {"value": "10000", "precision": 20}, "shipping_total": 10, "sales_channel_id": "sc_01KSCR9E3HDNX82KGM4FXZDGP1", "shipping_address": {"id": "caaddr_01KTBE9TP29YDC5XS55VC6JDRC", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": null, "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-06-05T08:27:25.250Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-06-05T08:27:25.250Z", "customer_id": null, "postal_code": "", "country_code": "bi"}, "shipping_methods": [{"id": "casm_01KTBEQN9Z4CQ6D3BNAD29CEDV", "data": {}, "name": "Standart", "total": 10, "amount": 10, "cart_id": "cart_01KT1VZFSW5FDQCERA8BX242EF", "metadata": null, "subtotal": 10, "raw_total": {"value": "10", "precision": 20}, "tax_lines": [], "tax_total": 0, "created_at": "2026-06-05T08:34:58.495Z", "deleted_at": null, "raw_amount": {"value": "10", "precision": 20}, "updated_at": "2026-06-05T08:34:58.495Z", "adjustments": [], "description": null, "raw_subtotal": {"value": "10", "precision": 20}, "raw_tax_total": {"value": "0", "precision": 20}, "discount_total": 0, "original_total": 10, "is_tax_inclusive": false, "discount_subtotal": 0, "original_subtotal": 10, "discount_tax_total": 0, "original_tax_total": 0, "raw_discount_total": {"value": "0", "precision": 20}, "raw_original_total": {"value": "10", "precision": 20}, "shipping_option_id": "so_01KTAFNNF59QWDVTRF6X6WJ9RG", "raw_discount_subtotal": {"value": "0", "precision": 20}, "raw_original_subtotal": {"value": "10", "precision": 20}, "raw_discount_tax_total": {"value": "0", "precision": 20}, "raw_original_tax_total": {"value": "0", "precision": 20}}], "raw_item_subtotal": {"value": "10000", "precision": 20}, "shipping_subtotal": 10, "discount_tax_total": 0, "original_tax_total": 0, "payment_collection": {"id": "pay_col_01KT6M0W172PCB6JW5MG36TPT6", "amount": 10010, "status": "not_paid", "metadata": null, "created_at": "2026-06-03T11:31:11.016Z", "deleted_at": null, "raw_amount": {"value": "10010", "precision": 20}, "updated_at": "2026-06-05T08:20:41.450Z", "completed_at": null, "currency_code": "usd", "captured_amount": null, "refunded_amount": null, "payment_sessions": [{"id": "payses_01KTBF4M5YKYG5X8XFNHBED1YX", "data": {"id": 79, "url": null, "status": "initiated", "message": "Payment request has been created in your Ihela account, please log in and confirm it <br>", "initiator": "9717", "sim_number": "9717", "external_ref": "2431_1780648923", "vendor_email": "princelulinda@gmail.com", "payment_method": "IHELA", "transaction_id": 79}, "amount": 10010, "status": "pending", "context": {"customer": {"id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "email": "princelulinda32@gmail.com", "phone": "76777777", "metadata": null, "addresses": [{"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}], "last_name": "lulinda", "first_name": "prince", "company_name": null, "account_holders": [{"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}, {"id": "acchld_01KT9CPTPVBND0XMSK9CFGCAJH", "data": {"customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8"}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-06-04T13:21:05.244Z", "deleted_at": null, "updated_at": "2026-06-04T13:21:05.244Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_kashflow_kashflow"}], "billing_address": {"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}}, "account_holder": {"id": "acchld_01KT9CPTPVBND0XMSK9CFGCAJH", "data": {"customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8"}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-06-04T13:21:05.244Z", "deleted_at": null, "updated_at": "2026-06-04T13:21:05.244Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_kashflow_kashflow"}}, "metadata": {}, "created_at": "2026-06-05T08:42:03.326Z", "deleted_at": null, "raw_amount": {"value": "10010", "precision": 20}, "updated_at": "2026-06-05T08:42:11.950Z", "provider_id": "pp_kashflow_kashflow", "authorized_at": null, "currency_code": "usd", "payment_collection_id": "pay_col_01KT6M0W172PCB6JW5MG36TPT6"}], "authorized_amount": null, "raw_captured_amount": null, "raw_refunded_amount": null, "raw_authorized_amount": null}, "raw_discount_total": {"value": "0", "precision": 20}, "raw_item_tax_total": {"value": "0", "precision": 20}, "raw_original_total": {"value": "10010", "precision": 20}, "raw_shipping_total": {"value": "10", "precision": 20}, "shipping_tax_total": 0, "original_item_total": 10000, "raw_shipping_subtotal": {"value": "10", "precision": 20}, "original_item_subtotal": 10000, "raw_discount_tax_total": {"value": "0", "precision": 20}, "raw_original_tax_total": {"value": "0", "precision": 20}, "raw_shipping_tax_total": {"value": "0", "precision": 20}, "original_item_tax_total": 0, "original_shipping_total": 10, "raw_original_item_total": {"value": "10000", "precision": 20}, "original_shipping_subtotal": 10, "raw_original_item_subtotal": {"value": "10000", "precision": 20}, "original_shipping_tax_total": 0, "raw_original_item_tax_total": {"value": "0", "precision": 20}, "raw_original_shipping_total": {"value": "10", "precision": 20}, "raw_original_shipping_subtotal": {"value": "10", "precision": 20}, "raw_original_shipping_tax_total": {"value": "0", "precision": 20}}}, "compensateInput": {"data": {"id": "cart_01KT1VZFSW5FDQCERA8BX242EF", "email": "princelulinda32@gmail.com", "items": [{"id": "cali_01KTA7Z2PX415ZRJRPT2NWMFDT", "title": "Ma saani", "total": 10000, "cart_id": "cart_01KT1VZFSW5FDQCERA8BX242EF", "variant": {"id": "variant_01KSDEEB4X5XQS5EZAMWG8KH96", "product": {"id": "prod_01KSDEEB3Y6W05F6K2ZV4GC0BM", "is_giftcard": false, "shipping_profile": {"id": "sp_01KSCR51Y68N200HV70RYQZGR2"}}, "product_id": "prod_01KSDEEB3Y6W05F6K2ZV4GC0BM", "allow_backorder": false, "inventory_items": [{"inventory": {"id": "iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX", "location_levels": [{"location_id": "sloc_01KSF7CHXY413KMNRYZAE8PT2S", "stock_locations": [{"id": "sloc_01KSF7CHXY413KMNRYZAE8PT2S", "name": "Bujumbura", "sales_channels": [{"id": "sc_01KSCR9E3HDNX82KGM4FXZDGP1", "name": "Default Sales Channel"}]}], "stocked_quantity": 95, "reserved_quantity": 7, "raw_stocked_quantity": {"value": "95", "precision": 20}, "raw_reserved_quantity": {"value": "7", "precision": 20}}], "requires_shipping": true}, "variant_id": "variant_01KSDEEB4X5XQS5EZAMWG8KH96", "inventory_item_id": "iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX", "required_quantity": 1}], "manage_inventory": true}, "metadata": {}, "quantity": 1, "subtitle": "Rouge", "subtotal": 10000, "raw_total": {"value": "10000", "precision": 20}, "tax_lines": [], "tax_total": 0, "thumbnail": "http://localhost:9000/static/1779641482219-image.jpg", "created_at": "2026-06-04T21:17:27.133Z", "deleted_at": null, "product_id": "prod_01KSDEEB3Y6W05F6K2ZV4GC0BM", "unit_price": 10000, "updated_at": "2026-06-04T21:17:27.133Z", "variant_id": "variant_01KSDEEB4X5XQS5EZAMWG8KH96", "adjustments": [], "is_giftcard": false, "variant_sku": null, "product_type": null, "raw_subtotal": {"value": "10000", "precision": 20}, "product_title": "Ma saani", "raw_tax_total": {"value": "0", "precision": 20}, "variant_title": "Rouge", "discount_total": 0, "original_total": 10000, "product_handle": "ma-saani", "raw_unit_price": {"value": "10000", "precision": 20}, "is_custom_price": false, "is_discountable": true, "product_type_id": null, "variant_barcode": null, "is_tax_inclusive": false, "product_subtitle": null, "discount_subtotal": 0, "original_subtotal": 10000, "requires_shipping": true, "discount_tax_total": 0, "original_tax_total": 0, "product_collection": null, "raw_discount_total": {"value": "0", "precision": 20}, "raw_original_total": {"value": "10000", "precision": 20}, "product_description": "Hello", "compare_at_unit_price": null, "raw_discount_subtotal": {"value": "0", "precision": 20}, "raw_original_subtotal": {"value": "10000", "precision": 20}, "variant_option_values": null, "raw_discount_tax_total": {"value": "0", "precision": 20}, "raw_original_tax_total": {"value": "0", "precision": 20}, "raw_compare_at_unit_price": null}], "total": 10010, "locale": null, "region": {"id": "reg_01KSR0QAP4C6SG0JX6SG5ZK6BP", "name": "East", "metadata": null, "created_at": "2026-05-28T19:24:33.371Z", "deleted_at": null, "updated_at": "2026-05-28T19:24:33.371Z", "currency_code": "usd", "automatic_taxes": false}, "customer": {"id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "email": "princelulinda32@gmail.com", "phone": "76777777", "metadata": null, "last_name": "lulinda", "created_at": "2026-05-28T19:33:10.221Z", "created_by": null, "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:33:10.221Z", "has_account": true, "company_name": null}, "metadata": null, "subtotal": 10010, "raw_total": {"value": "10010", "precision": 20}, "region_id": "reg_01KSR0QAP4C6SG0JX6SG5ZK6BP", "tax_total": 0, "created_at": "2026-06-01T15:14:02.176Z", "item_total": 10000, "promotions": [], "updated_at": "2026-06-05T08:27:25.250Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "completed_at": null, "credit_lines": [], "raw_subtotal": {"value": "10010", "precision": 20}, "currency_code": "usd", "item_subtotal": 10000, "raw_tax_total": {"value": "0", "precision": 20}, "discount_total": 0, "item_tax_total": 0, "original_total": 10010, "raw_item_total": {"value": "10000", "precision": 20}, "shipping_total": 10, "sales_channel_id": "sc_01KSCR9E3HDNX82KGM4FXZDGP1", "shipping_address": {"id": "caaddr_01KTBE9TP29YDC5XS55VC6JDRC", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": null, "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-06-05T08:27:25.250Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-06-05T08:27:25.250Z", "customer_id": null, "postal_code": "", "country_code": "bi"}, "shipping_methods": [{"id": "casm_01KTBEQN9Z4CQ6D3BNAD29CEDV", "data": {}, "name": "Standart", "total": 10, "amount": 10, "cart_id": "cart_01KT1VZFSW5FDQCERA8BX242EF", "metadata": null, "subtotal": 10, "raw_total": {"value": "10", "precision": 20}, "tax_lines": [], "tax_total": 0, "created_at": "2026-06-05T08:34:58.495Z", "deleted_at": null, "raw_amount": {"value": "10", "precision": 20}, "updated_at": "2026-06-05T08:34:58.495Z", "adjustments": [], "description": null, "raw_subtotal": {"value": "10", "precision": 20}, "raw_tax_total": {"value": "0", "precision": 20}, "discount_total": 0, "original_total": 10, "is_tax_inclusive": false, "discount_subtotal": 0, "original_subtotal": 10, "discount_tax_total": 0, "original_tax_total": 0, "raw_discount_total": {"value": "0", "precision": 20}, "raw_original_total": {"value": "10", "precision": 20}, "shipping_option_id": "so_01KTAFNNF59QWDVTRF6X6WJ9RG", "raw_discount_subtotal": {"value": "0", "precision": 20}, "raw_original_subtotal": {"value": "10", "precision": 20}, "raw_discount_tax_total": {"value": "0", "precision": 20}, "raw_original_tax_total": {"value": "0", "precision": 20}}], "raw_item_subtotal": {"value": "10000", "precision": 20}, "shipping_subtotal": 10, "discount_tax_total": 0, "original_tax_total": 0, "payment_collection": {"id": "pay_col_01KT6M0W172PCB6JW5MG36TPT6", "amount": 10010, "status": "not_paid", "metadata": null, "created_at": "2026-06-03T11:31:11.016Z", "deleted_at": null, "raw_amount": {"value": "10010", "precision": 20}, "updated_at": "2026-06-05T08:20:41.450Z", "completed_at": null, "currency_code": "usd", "captured_amount": null, "refunded_amount": null, "payment_sessions": [{"id": "payses_01KTBF4M5YKYG5X8XFNHBED1YX", "data": {"id": 79, "url": null, "status": "initiated", "message": "Payment request has been created in your Ihela account, please log in and confirm it <br>", "initiator": "9717", "sim_number": "9717", "external_ref": "2431_1780648923", "vendor_email": "princelulinda@gmail.com", "payment_method": "IHELA", "transaction_id": 79}, "amount": 10010, "status": "pending", "context": {"customer": {"id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "email": "princelulinda32@gmail.com", "phone": "76777777", "metadata": null, "addresses": [{"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}], "last_name": "lulinda", "first_name": "prince", "company_name": null, "account_holders": [{"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}, {"id": "acchld_01KT9CPTPVBND0XMSK9CFGCAJH", "data": {"customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8"}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-06-04T13:21:05.244Z", "deleted_at": null, "updated_at": "2026-06-04T13:21:05.244Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_kashflow_kashflow"}], "billing_address": {"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}}, "account_holder": {"id": "acchld_01KT9CPTPVBND0XMSK9CFGCAJH", "data": {"customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8"}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-06-04T13:21:05.244Z", "deleted_at": null, "updated_at": "2026-06-04T13:21:05.244Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_kashflow_kashflow"}}, "metadata": {}, "created_at": "2026-06-05T08:42:03.326Z", "deleted_at": null, "raw_amount": {"value": "10010", "precision": 20}, "updated_at": "2026-06-05T08:42:11.950Z", "provider_id": "pp_kashflow_kashflow", "authorized_at": null, "currency_code": "usd", "payment_collection_id": "pay_col_01KT6M0W172PCB6JW5MG36TPT6"}], "authorized_amount": null, "raw_captured_amount": null, "raw_refunded_amount": null, "raw_authorized_amount": null}, "raw_discount_total": {"value": "0", "precision": 20}, "raw_item_tax_total": {"value": "0", "precision": 20}, "raw_original_total": {"value": "10010", "precision": 20}, "raw_shipping_total": {"value": "10", "precision": 20}, "shipping_tax_total": 0, "original_item_total": 10000, "raw_shipping_subtotal": {"value": "10", "precision": 20}, "original_item_subtotal": 10000, "raw_discount_tax_total": {"value": "0", "precision": 20}, "raw_original_tax_total": {"value": "0", "precision": 20}, "raw_shipping_tax_total": {"value": "0", "precision": 20}, "original_item_tax_total": 0, "original_shipping_total": 10, "raw_original_item_total": {"value": "10000", "precision": 20}, "original_shipping_subtotal": 10, "raw_original_item_subtotal": {"value": "10000", "precision": 20}, "original_shipping_tax_total": 0, "raw_original_item_tax_total": {"value": "0", "precision": 20}, "raw_original_shipping_total": {"value": "10", "precision": 20}, "raw_original_shipping_subtotal": {"value": "10", "precision": 20}, "raw_original_shipping_tax_total": {"value": "0", "precision": 20}}}}}, "update-carts": {"__type": "Symbol(WorkflowWorkflowData)", "output": {"__type": "Symbol(WorkflowStepResponse)", "output": [{"id": "cart_01KT1VZFSW5FDQCERA8BX242EF", "email": "princelulinda32@gmail.com", "locale": null, "metadata": null, "region_id": "reg_01KSR0QAP4C6SG0JX6SG5ZK6BP", "created_at": "2026-06-01T15:14:02.176Z", "deleted_at": null, "updated_at": "2026-06-05T08:42:12.357Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "completed_at": "2026-06-05T08:42:12.301Z", "currency_code": "usd", "billing_address": null, "sales_channel_id": "sc_01KSCR9E3HDNX82KGM4FXZDGP1", "shipping_address": {"id": "caaddr_01KTBE9TP29YDC5XS55VC6JDRC"}, "billing_address_id": null, "shipping_address_id": "caaddr_01KTBE9TP29YDC5XS55VC6JDRC"}], "compensateInput": {"cartsBeforeUpdate": [{"id": "cart_01KT1VZFSW5FDQCERA8BX242EF", "email": "princelulinda32@gmail.com", "metadata": null, "region_id": "reg_01KSR0QAP4C6SG0JX6SG5ZK6BP", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "completed_at": null, "currency_code": "usd", "sales_channel_id": "sc_01KSCR9E3HDNX82KGM4FXZDGP1"}], "addressesBeforeUpdate": []}}}, "create-orders": {"__type": "Symbol(WorkflowWorkflowData)", "output": {"__type": "Symbol(WorkflowStepResponse)", "output": [{"id": "order_01KTBF4WV33ZQZ0VVF4TZTS0GV", "email": "princelulinda32@gmail.com", "items": [{"id": "ordli_01KTBF4WV6FZKQQT9S5B1EKMPW", "title": "Ma saani", "detail": {"id": "orditem_01KTBF4WV8P9K71Q07B93HW8K0", "item_id": "ordli_01KTBF4WV6FZKQQT9S5B1EKMPW", "version": 1, "metadata": null, "order_id": "order_01KTBF4WV33ZQZ0VVF4TZTS0GV", "quantity": 1, "created_at": "2026-06-05T08:42:12.204Z", "deleted_at": null, "unit_price": null, "updated_at": "2026-06-05T08:42:12.204Z", "raw_quantity": {"value": "1", "precision": 20}, "raw_unit_price": null, "shipped_quantity": 0, "delivered_quantity": 0, "fulfilled_quantity": 0, "raw_shipped_quantity": {"value": "0", "precision": 20}, "written_off_quantity": 0, "compare_at_unit_price": null, "raw_delivered_quantity": {"value": "0", "precision": 20}, "raw_fulfilled_quantity": {"value": "0", "precision": 20}, "raw_written_off_quantity": {"value": "0", "precision": 20}, "return_received_quantity": 0, "raw_compare_at_unit_price": null, "return_dismissed_quantity": 0, "return_requested_quantity": 0, "raw_return_received_quantity": {"value": "0", "precision": 20}, "raw_return_dismissed_quantity": {"value": "0", "precision": 20}, "raw_return_requested_quantity": {"value": "0", "precision": 20}}, "metadata": {}, "quantity": 1, "subtitle": "Rouge", "tax_lines": [], "thumbnail": "http://localhost:9000/static/1779641482219-image.jpg", "created_at": "2026-06-05T08:42:12.204Z", "deleted_at": null, "product_id": "prod_01KSDEEB3Y6W05F6K2ZV4GC0BM", "unit_price": 10000, "updated_at": "2026-06-05T08:42:12.204Z", "variant_id": "variant_01KSDEEB4X5XQS5EZAMWG8KH96", "adjustments": [], "is_giftcard": false, "variant_sku": null, "product_type": null, "raw_quantity": {"value": "1", "precision": 20}, "product_title": "Ma saani", "variant_title": "Rouge", "product_handle": "ma-saani", "raw_unit_price": {"value": "10000", "precision": 20}, "is_custom_price": false, "is_discountable": true, "product_type_id": null, "variant_barcode": null, "is_tax_inclusive": false, "product_subtitle": null, "requires_shipping": true, "product_collection": null, "product_description": "Hello", "compare_at_unit_price": null, "variant_option_values": null, "raw_compare_at_unit_price": null}], "locale": null, "status": "pending", "summary": {"paid_total": 0, "raw_paid_total": {"value": "0", "precision": 20}, "refunded_total": 0, "accounting_total": 10010, "credit_line_total": 0, "transaction_total": 0, "pending_difference": 10010, "raw_refunded_total": {"value": "0", "precision": 20}, "current_order_total": 10010, "original_order_total": 10010, "raw_accounting_total": {"value": "10010", "precision": 20}, "raw_credit_line_total": {"value": "0", "precision": 20}, "raw_transaction_total": {"value": "0", "precision": 20}, "raw_pending_difference": {"value": "10010", "precision": 20}, "raw_current_order_total": {"value": "10010", "precision": 20}, "raw_original_order_total": {"value": "10010", "precision": 20}}, "version": 1, "metadata": null, "region_id": "reg_01KSR0QAP4C6SG0JX6SG5ZK6BP", "created_at": "2026-06-05T08:42:12.203Z", "deleted_at": null, "display_id": 15, "updated_at": "2026-06-05T08:42:12.203Z", "canceled_at": null, "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "credit_lines": [], "transactions": [], "currency_code": "usd", "is_draft_order": false, "billing_address": null, "no_notification": false, "sales_channel_id": "sc_01KSCR9E3HDNX82KGM4FXZDGP1", "shipping_address": {"id": "ordaddr_01KTBF4WTQMVKDB2012QPT7PAR", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": null, "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-06-05T08:27:25.250Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-06-05T08:27:25.250Z", "customer_id": null, "postal_code": "", "country_code": "bi"}, "shipping_methods": [{"id": "ordsm_01KTBF4WV2RBW4QWTFAPV8SSRZ", "data": {}, "name": "Standart", "amount": 10, "detail": {"id": "ordspmv_01KTBF4WV23NSFDCCVMFX7TB2T", "version": 1, "claim_id": null, "order_id": "order_01KTBF4WV33ZQZ0VVF4TZTS0GV", "return_id": null, "created_at": "2026-06-05T08:42:12.206Z", "deleted_at": null, "updated_at": "2026-06-05T08:42:12.206Z", "exchange_id": null, "shipping_method_id": "ordsm_01KTBF4WV2RBW4QWTFAPV8SSRZ"}, "metadata": null, "order_id": "order_01KTBF4WV33ZQZ0VVF4TZTS0GV", "tax_lines": [], "created_at": "2026-06-05T08:42:12.205Z", "deleted_at": null, "raw_amount": {"value": "10", "precision": 20}, "updated_at": "2026-06-05T08:42:12.205Z", "adjustments": [], "description": null, "is_custom_amount": false, "is_tax_inclusive": false, "shipping_option_id": "so_01KTAFNNF59QWDVTRF6X6WJ9RG"}], "custom_display_id": null, "shipping_address_id": "ordaddr_01KTBF4WTQMVKDB2012QPT7PAR"}], "compensateInput": ["order_01KTBF4WV33ZQZ0VVF4TZTS0GV"]}}, "register-usage": {"__type": "Symbol(WorkflowWorkflowData)", "output": {"__type": "Symbol(WorkflowStepResponse)", "output": null, "compensateInput": {"computedActions": [], "registrationContext": {"customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "customer_email": "princelulinda32@gmail.com"}}}}, "emit-event-step": {"__type": "Symbol(WorkflowWorkflowData)", "output": {"__type": "Symbol(WorkflowStepResponse)", "output": {"eventName": "order.placed", "eventGroupId": "01KTBF4WNWGWQVSQYE9DKKYN8J"}, "compensateInput": {"eventName": "order.placed", "eventGroupId": "01KTBF4WNWGWQVSQYE9DKKYN8J"}}}, "validate-shipping": {"__type": "Symbol(WorkflowWorkflowData)", "output": {"__type": "Symbol(WorkflowStepResponse)"}}, "create-remote-links": {"__type": "Symbol(WorkflowWorkflowData)", "output": {"__type": "Symbol(WorkflowStepResponse)", "output": [{"cart": {"cart_id": "cart_01KT1VZFSW5FDQCERA8BX242EF"}, "order": {"order_id": "order_01KTBF4WV33ZQZ0VVF4TZTS0GV"}}, {"order": {"order_id": "order_01KTBF4WV33ZQZ0VVF4TZTS0GV"}, "payment": {"payment_collection_id": "pay_col_01KT6M0W172PCB6JW5MG36TPT6"}}], "compensateInput": [{"cart": {"cart_id": "cart_01KT1VZFSW5FDQCERA8BX242EF"}, "order": {"order_id": "order_01KTBF4WV33ZQZ0VVF4TZTS0GV"}}, {"order": {"order_id": "order_01KTBF4WV33ZQZ0VVF4TZTS0GV"}, "payment": {"payment_collection_id": "pay_col_01KT6M0W172PCB6JW5MG36TPT6"}}]}}, "use-query-graph-step": {"__type": "Symbol(WorkflowWorkflowData)", "output": {"__type": "Symbol(WorkflowStepResponse)", "output": {}, "compensateInput": {}}}, "reserve-inventory-step": {"__type": "Symbol(WorkflowWorkflowData)", "output": {"__type": "Symbol(WorkflowStepResponse)", "output": [{"id": "resitem_01KTBF4WZHP80G3B2PJWH0320X", "metadata": null, "quantity": 1, "created_at": "2026-06-05T08:42:12.353Z", "created_by": null, "deleted_at": null, "updated_at": "2026-06-05T08:42:12.353Z", "description": null, "external_id": null, "location_id": "sloc_01KSF7CHXY413KMNRYZAE8PT2S", "line_item_id": "ordli_01KTBF4WV6FZKQQT9S5B1EKMPW", "raw_quantity": {"value": "1", "precision": 20}, "allow_backorder": false, "inventory_item_id": "iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX"}], "compensateInput": {"reservations": ["resitem_01KTBF4WZHP80G3B2PJWH0320X"], "inventoryItemIds": ["iitem_01KSDEEB53GKCC3VBRQ6MQ9FKX"]}}}, "shipping-options-query": {"__type": "Symbol(WorkflowWorkflowData)", "output": {"__type": "Symbol(WorkflowStepResponse)", "output": {"data": [{"id": "so_01KTAFNNF59QWDVTRF6X6WJ9RG", "shipping_profile_id": "sp_01KSCR51Y68N200HV70RYQZGR2"}]}, "compensateInput": {"data": [{"id": "so_01KTAFNNF59QWDVTRF6X6WJ9RG", "shipping_profile_id": "sp_01KSCR51Y68N200HV70RYQZGR2"}]}}}, "validate-cart-payments": {"__type": "Symbol(WorkflowWorkflowData)", "output": {"__type": "Symbol(WorkflowStepResponse)", "output": [{"id": "payses_01KTBF4M5YKYG5X8XFNHBED1YX", "data": {"id": 79, "url": null, "status": "initiated", "message": "Payment request has been created in your Ihela account, please log in and confirm it <br>", "initiator": "9717", "sim_number": "9717", "external_ref": "2431_1780648923", "vendor_email": "princelulinda@gmail.com", "payment_method": "IHELA", "transaction_id": 79}, "amount": 10010, "status": "pending", "context": {"customer": {"id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "email": "princelulinda32@gmail.com", "phone": "76777777", "metadata": null, "addresses": [{"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}], "last_name": "lulinda", "first_name": "prince", "company_name": null, "account_holders": [{"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}, {"id": "acchld_01KT9CPTPVBND0XMSK9CFGCAJH", "data": {"customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8"}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-06-04T13:21:05.244Z", "deleted_at": null, "updated_at": "2026-06-04T13:21:05.244Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_kashflow_kashflow"}], "billing_address": {"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}}, "account_holder": {"id": "acchld_01KT9CPTPVBND0XMSK9CFGCAJH", "data": {"customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8"}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-06-04T13:21:05.244Z", "deleted_at": null, "updated_at": "2026-06-04T13:21:05.244Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_kashflow_kashflow"}}, "metadata": {}, "created_at": "2026-06-05T08:42:03.326Z", "deleted_at": null, "raw_amount": {"value": "10010", "precision": 20}, "updated_at": "2026-06-05T08:42:11.950Z", "provider_id": "pp_kashflow_kashflow", "authorized_at": null, "currency_code": "usd", "payment_collection_id": "pay_col_01KT6M0W172PCB6JW5MG36TPT6"}], "compensateInput": [{"id": "payses_01KTBF4M5YKYG5X8XFNHBED1YX", "data": {"id": 79, "url": null, "status": "initiated", "message": "Payment request has been created in your Ihela account, please log in and confirm it <br>", "initiator": "9717", "sim_number": "9717", "external_ref": "2431_1780648923", "vendor_email": "princelulinda@gmail.com", "payment_method": "IHELA", "transaction_id": 79}, "amount": 10010, "status": "pending", "context": {"customer": {"id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "email": "princelulinda32@gmail.com", "phone": "76777777", "metadata": null, "addresses": [{"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}], "last_name": "lulinda", "first_name": "prince", "company_name": null, "account_holders": [{"id": "acchld_01KSYNR3BVMPX2V3KKBG485GEQ", "data": {}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-05-31T09:27:25.307Z", "deleted_at": null, "updated_at": "2026-05-31T09:27:25.307Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_system_default"}, {"id": "acchld_01KT9CPTPVBND0XMSK9CFGCAJH", "data": {"customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8"}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-06-04T13:21:05.244Z", "deleted_at": null, "updated_at": "2026-06-04T13:21:05.244Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_kashflow_kashflow"}], "billing_address": {"id": "cuaddr_01KSR1BKSFHXS9Z8FXMA530N89", "city": "Musenyi", "phone": "", "company": null, "metadata": null, "province": "Bubanza", "address_1": "Line", "address_2": "", "last_name": "lulinda", "created_at": "2026-05-28T19:35:38.031Z", "deleted_at": null, "first_name": "prince", "updated_at": "2026-05-28T19:35:38.031Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "postal_code": "", "address_name": null, "country_code": "bi", "is_default_billing": false, "is_default_shipping": false}}, "account_holder": {"id": "acchld_01KT9CPTPVBND0XMSK9CFGCAJH", "data": {"customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8"}, "email": "princelulinda32@gmail.com", "metadata": null, "created_at": "2026-06-04T13:21:05.244Z", "deleted_at": null, "updated_at": "2026-06-04T13:21:05.244Z", "external_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "provider_id": "pp_kashflow_kashflow"}}, "metadata": {}, "created_at": "2026-06-05T08:42:03.326Z", "deleted_at": null, "raw_amount": {"value": "10010", "precision": 20}, "updated_at": "2026-06-05T08:42:11.950Z", "provider_id": "pp_kashflow_kashflow", "authorized_at": null, "currency_code": "usd", "payment_collection_id": "pay_col_01KT6M0W172PCB6JW5MG36TPT6"}]}}, "beforePaymentAuthorization": {"__type": "Symbol(WorkflowWorkflowData)", "output": {"__type": "Symbol(WorkflowStepResponse)"}}, "compensate-payment-if-needed": {"__type": "Symbol(WorkflowWorkflowData)", "output": {"__type": "Symbol(WorkflowStepResponse)", "output": "payses_01KTBF4M5YKYG5X8XFNHBED1YX", "compensateInput": "payses_01KTBF4M5YKYG5X8XFNHBED1YX"}}}, "payload": {"id": "cart_01KT1VZFSW5FDQCERA8BX242EF"}, "compensate": {"validate": {}, "update-carts": {"output": [{"id": "cart_01KT1VZFSW5FDQCERA8BX242EF", "email": "princelulinda32@gmail.com", "locale": null, "metadata": null, "region_id": "reg_01KSR0QAP4C6SG0JX6SG5ZK6BP", "created_at": "2026-06-01T15:14:02.176Z", "deleted_at": null, "updated_at": "2026-06-05T08:42:12.459Z", "customer_id": "cus_01KSR173ECD4A2AJF6H3R1H2J8", "completed_at": null, "currency_code": "usd", "billing_address": null, "sales_channel_id": "sc_01KSCR9E3HDNX82KGM4FXZDGP1", "shipping_address": {"id": "caaddr_01KTBE9TP29YDC5XS55VC6JDRC"}, "billing_address_id": null, "shipping_address_id": "caaddr_01KTBE9TP29YDC5XS55VC6JDRC"}]}, "create-orders": {}, "register-usage": {}, "emit-event-step": {}, "create-remote-links": {}, "reserve-inventory-step": {"output": {"__type": "Symbol(WorkflowStepResponse)"}}, "beforePaymentAuthorization": {}, "compensate-payment-if-needed": {}, "authorize-payment-session-step": {}}}, "errors": [{"error": {"date": "2026-06-05T08:42:12.391Z", "name": "Error", "type": "not_allowed", "stack": "Error: Session: payses_01KTBF4M5YKYG5X8XFNHBED1YX was not authorized with the provider.\\n    at PaymentModuleService.authorizePaymentSession (/home/princelulinda/Documents/projects/eastmarket_backend/node_modules/@medusajs/payment/src/services/payment-module.ts:547:13)\\n    at processTicksAndRejections (node:internal/process/task_queues:104:5)\\n    at async PaymentModuleService.descriptor.value (/home/princelulinda/Documents/projects/eastmarket_backend/node_modules/@medusajs/utils/src/modules-sdk/decorators/inject-into-context.ts:27:14)\\n    at async PaymentModuleService.descriptor.value (/home/princelulinda/Documents/projects/eastmarket_backend/node_modules/@medusajs/utils/src/modules-sdk/decorators/emit-events.ts:26:22)\\n    at async Object.exports.authorizePaymentSessionStep.async.container.container (/home/princelulinda/Documents/projects/eastmarket_backend/node_modules/@medusajs/core-flows/src/payment/steps/authorize-payment-session.ts:53:17)\\n    at async invoke (/home/princelulinda/Documents/projects/eastmarket_backend/node_modules/@medusajs/workflows-sdk/src/utils/composer/helpers/create-step-handler.ts:91:52)\\n    at async Object.handle.invoke (/home/princelulinda/Documents/projects/eastmarket_backend/node_modules/@medusajs/workflows-sdk/src/utils/composer/create-step.ts:381:12)\\n    at async DistributedTransaction.handler (/home/princelulinda/Documents/projects/eastmarket_backend/node_modules/@medusajs/orchestration/src/workflow/workflow-manager.ts:214:16)\\n    at async stepHandler (/home/princelulinda/Documents/projects/eastmarket_backend/node_modules/@medusajs/orchestration/src/transaction/transaction-orchestrator.ts:1186:14)\\n    at async Promise.allSettled (index 0)\\n⮑ sat /home/princelulinda/Documents/projects/eastmarket_backend/node_modules/@medusajs/core-flows/dist/cart/workflows/complete-cart.js: [complete-cart -> authorize-payment-session-step (invoke)]", "message": "Session: payses_01KTBF4M5YKYG5X8XFNHBED1YX was not authorized with the provider.", "__isMedusaError": true}, "action": "authorize-payment-session-step", "handlerType": "invoke"}]}	reverted	2026-06-05 08:42:12.064	2026-06-05 08:42:12.548	\N	259200	01KTBF4WP1NMKTT7VK9FVNBP90
\.


--
-- Name: link_module_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: princelulinda
--

SELECT pg_catalog.setval('public.link_module_migrations_id_seq', 352, true);


--
-- Name: mikro_orm_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: princelulinda
--

SELECT pg_catalog.setval('public.mikro_orm_migrations_id_seq', 175, true);


--
-- Name: order_change_action_ordering_seq; Type: SEQUENCE SET; Schema: public; Owner: princelulinda
--

SELECT pg_catalog.setval('public.order_change_action_ordering_seq', 6, true);


--
-- Name: order_claim_display_id_seq; Type: SEQUENCE SET; Schema: public; Owner: princelulinda
--

SELECT pg_catalog.setval('public.order_claim_display_id_seq', 1, false);


--
-- Name: order_display_id_seq; Type: SEQUENCE SET; Schema: public; Owner: princelulinda
--

SELECT pg_catalog.setval('public.order_display_id_seq', 15, true);


--
-- Name: order_exchange_display_id_seq; Type: SEQUENCE SET; Schema: public; Owner: princelulinda
--

SELECT pg_catalog.setval('public.order_exchange_display_id_seq', 1, false);


--
-- Name: return_display_id_seq; Type: SEQUENCE SET; Schema: public; Owner: princelulinda
--

SELECT pg_catalog.setval('public.return_display_id_seq', 1, false);


--
-- Name: script_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: princelulinda
--

SELECT pg_catalog.setval('public.script_migrations_id_seq', 2, true);


--
-- Name: account_holder account_holder_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.account_holder
    ADD CONSTRAINT account_holder_pkey PRIMARY KEY (id);


--
-- Name: analytics_event analytics_event_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.analytics_event
    ADD CONSTRAINT analytics_event_pkey PRIMARY KEY (id);


--
-- Name: api_key api_key_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.api_key
    ADD CONSTRAINT api_key_pkey PRIMARY KEY (id);


--
-- Name: app_notification app_notification_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.app_notification
    ADD CONSTRAINT app_notification_pkey PRIMARY KEY (id);


--
-- Name: application_method_buy_rules application_method_buy_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.application_method_buy_rules
    ADD CONSTRAINT application_method_buy_rules_pkey PRIMARY KEY (application_method_id, promotion_rule_id);


--
-- Name: application_method_target_rules application_method_target_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.application_method_target_rules
    ADD CONSTRAINT application_method_target_rules_pkey PRIMARY KEY (application_method_id, promotion_rule_id);


--
-- Name: auth_identity auth_identity_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.auth_identity
    ADD CONSTRAINT auth_identity_pkey PRIMARY KEY (id);


--
-- Name: capture capture_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.capture
    ADD CONSTRAINT capture_pkey PRIMARY KEY (id);


--
-- Name: cart_address cart_address_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.cart_address
    ADD CONSTRAINT cart_address_pkey PRIMARY KEY (id);


--
-- Name: cart_line_item_adjustment cart_line_item_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.cart_line_item_adjustment
    ADD CONSTRAINT cart_line_item_adjustment_pkey PRIMARY KEY (id);


--
-- Name: cart_line_item cart_line_item_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.cart_line_item
    ADD CONSTRAINT cart_line_item_pkey PRIMARY KEY (id);


--
-- Name: cart_line_item_tax_line cart_line_item_tax_line_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.cart_line_item_tax_line
    ADD CONSTRAINT cart_line_item_tax_line_pkey PRIMARY KEY (id);


--
-- Name: cart_payment_collection cart_payment_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.cart_payment_collection
    ADD CONSTRAINT cart_payment_collection_pkey PRIMARY KEY (cart_id, payment_collection_id);


--
-- Name: cart cart_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_pkey PRIMARY KEY (id);


--
-- Name: cart_promotion cart_promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.cart_promotion
    ADD CONSTRAINT cart_promotion_pkey PRIMARY KEY (cart_id, promotion_id);


--
-- Name: cart_shipping_method_adjustment cart_shipping_method_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.cart_shipping_method_adjustment
    ADD CONSTRAINT cart_shipping_method_adjustment_pkey PRIMARY KEY (id);


--
-- Name: cart_shipping_method cart_shipping_method_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.cart_shipping_method
    ADD CONSTRAINT cart_shipping_method_pkey PRIMARY KEY (id);


--
-- Name: cart_shipping_method_tax_line cart_shipping_method_tax_line_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.cart_shipping_method_tax_line
    ADD CONSTRAINT cart_shipping_method_tax_line_pkey PRIMARY KEY (id);


--
-- Name: conversation conversation_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.conversation
    ADD CONSTRAINT conversation_pkey PRIMARY KEY (id);


--
-- Name: credit_line credit_line_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.credit_line
    ADD CONSTRAINT credit_line_pkey PRIMARY KEY (id);


--
-- Name: currency currency_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.currency
    ADD CONSTRAINT currency_pkey PRIMARY KEY (code);


--
-- Name: customer_account_holder customer_account_holder_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.customer_account_holder
    ADD CONSTRAINT customer_account_holder_pkey PRIMARY KEY (customer_id, account_holder_id);


--
-- Name: customer_address customer_address_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.customer_address
    ADD CONSTRAINT customer_address_pkey PRIMARY KEY (id);


--
-- Name: customer_group_customer customer_group_customer_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.customer_group_customer
    ADD CONSTRAINT customer_group_customer_pkey PRIMARY KEY (id);


--
-- Name: customer_group customer_group_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.customer_group
    ADD CONSTRAINT customer_group_pkey PRIMARY KEY (id);


--
-- Name: customer_payment_method customer_payment_method_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.customer_payment_method
    ADD CONSTRAINT customer_payment_method_pkey PRIMARY KEY (id);


--
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (id);


--
-- Name: delivery_company delivery_company_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.delivery_company
    ADD CONSTRAINT delivery_company_pkey PRIMARY KEY (id);


--
-- Name: delivery_delivery_company_fulfillment_shipping_option delivery_delivery_company_fulfillment_shipping_option_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.delivery_delivery_company_fulfillment_shipping_option
    ADD CONSTRAINT delivery_delivery_company_fulfillment_shipping_option_pkey PRIMARY KEY (delivery_company_id, shipping_option_id);


--
-- Name: delivery_driver delivery_driver_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.delivery_driver
    ADD CONSTRAINT delivery_driver_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_address fulfillment_address_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.fulfillment_address
    ADD CONSTRAINT fulfillment_address_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_item fulfillment_item_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.fulfillment_item
    ADD CONSTRAINT fulfillment_item_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_label fulfillment_label_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.fulfillment_label
    ADD CONSTRAINT fulfillment_label_pkey PRIMARY KEY (id);


--
-- Name: fulfillment fulfillment_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT fulfillment_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_provider fulfillment_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.fulfillment_provider
    ADD CONSTRAINT fulfillment_provider_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_set fulfillment_set_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.fulfillment_set
    ADD CONSTRAINT fulfillment_set_pkey PRIMARY KEY (id);


--
-- Name: geo_zone geo_zone_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.geo_zone
    ADD CONSTRAINT geo_zone_pkey PRIMARY KEY (id);


--
-- Name: image image_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_pkey PRIMARY KEY (id);


--
-- Name: inventory_item inventory_item_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.inventory_item
    ADD CONSTRAINT inventory_item_pkey PRIMARY KEY (id);


--
-- Name: inventory_level inventory_level_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.inventory_level
    ADD CONSTRAINT inventory_level_pkey PRIMARY KEY (id);


--
-- Name: invite invite_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.invite
    ADD CONSTRAINT invite_pkey PRIMARY KEY (id);


--
-- Name: link_module_migrations link_module_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.link_module_migrations
    ADD CONSTRAINT link_module_migrations_pkey PRIMARY KEY (id);


--
-- Name: link_module_migrations link_module_migrations_table_name_key; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.link_module_migrations
    ADD CONSTRAINT link_module_migrations_table_name_key UNIQUE (table_name);


--
-- Name: locale locale_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.locale
    ADD CONSTRAINT locale_pkey PRIMARY KEY (id);


--
-- Name: location_fulfillment_provider location_fulfillment_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.location_fulfillment_provider
    ADD CONSTRAINT location_fulfillment_provider_pkey PRIMARY KEY (stock_location_id, fulfillment_provider_id);


--
-- Name: location_fulfillment_set location_fulfillment_set_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.location_fulfillment_set
    ADD CONSTRAINT location_fulfillment_set_pkey PRIMARY KEY (stock_location_id, fulfillment_set_id);


--
-- Name: marketplace_vendor_order_order marketplace_vendor_order_order_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.marketplace_vendor_order_order
    ADD CONSTRAINT marketplace_vendor_order_order_pkey PRIMARY KEY (vendor_id, order_id);


--
-- Name: marketplace_vendor_product_product marketplace_vendor_product_product_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.marketplace_vendor_product_product
    ADD CONSTRAINT marketplace_vendor_product_product_pkey PRIMARY KEY (vendor_id, product_id);


--
-- Name: marketplace_vendor_promotion_promotion marketplace_vendor_promotion_promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.marketplace_vendor_promotion_promotion
    ADD CONSTRAINT marketplace_vendor_promotion_promotion_pkey PRIMARY KEY (vendor_id, promotion_id);


--
-- Name: marketplace_vendor_stock_location_stock_location marketplace_vendor_stock_location_stock_location_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.marketplace_vendor_stock_location_stock_location
    ADD CONSTRAINT marketplace_vendor_stock_location_stock_location_pkey PRIMARY KEY (vendor_id, stock_location_id);


--
-- Name: message message_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.message
    ADD CONSTRAINT message_pkey PRIMARY KEY (id);


--
-- Name: mikro_orm_migrations mikro_orm_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.mikro_orm_migrations
    ADD CONSTRAINT mikro_orm_migrations_pkey PRIMARY KEY (id);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- Name: notification_provider notification_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.notification_provider
    ADD CONSTRAINT notification_provider_pkey PRIMARY KEY (id);


--
-- Name: order_address order_address_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_address
    ADD CONSTRAINT order_address_pkey PRIMARY KEY (id);


--
-- Name: order_cart order_cart_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_cart
    ADD CONSTRAINT order_cart_pkey PRIMARY KEY (order_id, cart_id);


--
-- Name: order_change_action order_change_action_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_change_action
    ADD CONSTRAINT order_change_action_pkey PRIMARY KEY (id);


--
-- Name: order_change order_change_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_change
    ADD CONSTRAINT order_change_pkey PRIMARY KEY (id);


--
-- Name: order_claim_item_image order_claim_item_image_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_claim_item_image
    ADD CONSTRAINT order_claim_item_image_pkey PRIMARY KEY (id);


--
-- Name: order_claim_item order_claim_item_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_claim_item
    ADD CONSTRAINT order_claim_item_pkey PRIMARY KEY (id);


--
-- Name: order_claim order_claim_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_claim
    ADD CONSTRAINT order_claim_pkey PRIMARY KEY (id);


--
-- Name: order_credit_line order_credit_line_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_credit_line
    ADD CONSTRAINT order_credit_line_pkey PRIMARY KEY (id);


--
-- Name: order_exchange_item order_exchange_item_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_exchange_item
    ADD CONSTRAINT order_exchange_item_pkey PRIMARY KEY (id);


--
-- Name: order_exchange order_exchange_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_exchange
    ADD CONSTRAINT order_exchange_pkey PRIMARY KEY (id);


--
-- Name: order_fulfillment order_fulfillment_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_fulfillment
    ADD CONSTRAINT order_fulfillment_pkey PRIMARY KEY (order_id, fulfillment_id);


--
-- Name: order_item order_item_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_pkey PRIMARY KEY (id);


--
-- Name: order_line_item_adjustment order_line_item_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_line_item_adjustment
    ADD CONSTRAINT order_line_item_adjustment_pkey PRIMARY KEY (id);


--
-- Name: order_line_item order_line_item_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_line_item
    ADD CONSTRAINT order_line_item_pkey PRIMARY KEY (id);


--
-- Name: order_line_item_tax_line order_line_item_tax_line_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_line_item_tax_line
    ADD CONSTRAINT order_line_item_tax_line_pkey PRIMARY KEY (id);


--
-- Name: order_payment_collection order_payment_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_payment_collection
    ADD CONSTRAINT order_payment_collection_pkey PRIMARY KEY (order_id, payment_collection_id);


--
-- Name: order order_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_pkey PRIMARY KEY (id);


--
-- Name: order_promotion order_promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_promotion
    ADD CONSTRAINT order_promotion_pkey PRIMARY KEY (order_id, promotion_id);


--
-- Name: order_shipping_method_adjustment order_shipping_method_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_shipping_method_adjustment
    ADD CONSTRAINT order_shipping_method_adjustment_pkey PRIMARY KEY (id);


--
-- Name: order_shipping_method order_shipping_method_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_shipping_method
    ADD CONSTRAINT order_shipping_method_pkey PRIMARY KEY (id);


--
-- Name: order_shipping_method_tax_line order_shipping_method_tax_line_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_shipping_method_tax_line
    ADD CONSTRAINT order_shipping_method_tax_line_pkey PRIMARY KEY (id);


--
-- Name: order_shipping order_shipping_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_shipping
    ADD CONSTRAINT order_shipping_pkey PRIMARY KEY (id);


--
-- Name: order_summary order_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_summary
    ADD CONSTRAINT order_summary_pkey PRIMARY KEY (id);


--
-- Name: order_transaction order_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_transaction
    ADD CONSTRAINT order_transaction_pkey PRIMARY KEY (id);


--
-- Name: payment_collection_payment_providers payment_collection_payment_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.payment_collection_payment_providers
    ADD CONSTRAINT payment_collection_payment_providers_pkey PRIMARY KEY (payment_collection_id, payment_provider_id);


--
-- Name: payment_collection payment_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.payment_collection
    ADD CONSTRAINT payment_collection_pkey PRIMARY KEY (id);


--
-- Name: payment payment_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (id);


--
-- Name: payment_provider payment_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.payment_provider
    ADD CONSTRAINT payment_provider_pkey PRIMARY KEY (id);


--
-- Name: payment_session payment_session_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.payment_session
    ADD CONSTRAINT payment_session_pkey PRIMARY KEY (id);


--
-- Name: price_list price_list_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.price_list
    ADD CONSTRAINT price_list_pkey PRIMARY KEY (id);


--
-- Name: price_list_rule price_list_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.price_list_rule
    ADD CONSTRAINT price_list_rule_pkey PRIMARY KEY (id);


--
-- Name: price price_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT price_pkey PRIMARY KEY (id);


--
-- Name: price_preference price_preference_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.price_preference
    ADD CONSTRAINT price_preference_pkey PRIMARY KEY (id);


--
-- Name: price_rule price_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.price_rule
    ADD CONSTRAINT price_rule_pkey PRIMARY KEY (id);


--
-- Name: price_set price_set_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.price_set
    ADD CONSTRAINT price_set_pkey PRIMARY KEY (id);


--
-- Name: product_category product_category_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_category
    ADD CONSTRAINT product_category_pkey PRIMARY KEY (id);


--
-- Name: product_category_product product_category_product_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_category_product
    ADD CONSTRAINT product_category_product_pkey PRIMARY KEY (product_id, product_category_id);


--
-- Name: product_collection product_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_collection
    ADD CONSTRAINT product_collection_pkey PRIMARY KEY (id);


--
-- Name: product_option product_option_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_option
    ADD CONSTRAINT product_option_pkey PRIMARY KEY (id);


--
-- Name: product_option_value product_option_value_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_option_value
    ADD CONSTRAINT product_option_value_pkey PRIMARY KEY (id);


--
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);


--
-- Name: product_sales_channel product_sales_channel_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_sales_channel
    ADD CONSTRAINT product_sales_channel_pkey PRIMARY KEY (product_id, sales_channel_id);


--
-- Name: product_shipping_profile product_shipping_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_shipping_profile
    ADD CONSTRAINT product_shipping_profile_pkey PRIMARY KEY (product_id, shipping_profile_id);


--
-- Name: product_tag product_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_tag
    ADD CONSTRAINT product_tag_pkey PRIMARY KEY (id);


--
-- Name: product_tags product_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_tags
    ADD CONSTRAINT product_tags_pkey PRIMARY KEY (product_id, product_tag_id);


--
-- Name: product_type product_type_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_type
    ADD CONSTRAINT product_type_pkey PRIMARY KEY (id);


--
-- Name: product_variant_inventory_item product_variant_inventory_item_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_variant_inventory_item
    ADD CONSTRAINT product_variant_inventory_item_pkey PRIMARY KEY (variant_id, inventory_item_id);


--
-- Name: product_variant_option product_variant_option_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_variant_option
    ADD CONSTRAINT product_variant_option_pkey PRIMARY KEY (variant_id, option_value_id);


--
-- Name: product_variant product_variant_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_variant
    ADD CONSTRAINT product_variant_pkey PRIMARY KEY (id);


--
-- Name: product_variant_price_set product_variant_price_set_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_variant_price_set
    ADD CONSTRAINT product_variant_price_set_pkey PRIMARY KEY (variant_id, price_set_id);


--
-- Name: product_variant_product_image product_variant_product_image_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_variant_product_image
    ADD CONSTRAINT product_variant_product_image_pkey PRIMARY KEY (id);


--
-- Name: promotion_application_method promotion_application_method_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.promotion_application_method
    ADD CONSTRAINT promotion_application_method_pkey PRIMARY KEY (id);


--
-- Name: promotion_campaign_budget promotion_campaign_budget_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.promotion_campaign_budget
    ADD CONSTRAINT promotion_campaign_budget_pkey PRIMARY KEY (id);


--
-- Name: promotion_campaign_budget_usage promotion_campaign_budget_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.promotion_campaign_budget_usage
    ADD CONSTRAINT promotion_campaign_budget_usage_pkey PRIMARY KEY (id);


--
-- Name: promotion_campaign promotion_campaign_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.promotion_campaign
    ADD CONSTRAINT promotion_campaign_pkey PRIMARY KEY (id);


--
-- Name: promotion promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_pkey PRIMARY KEY (id);


--
-- Name: promotion_promotion_rule promotion_promotion_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.promotion_promotion_rule
    ADD CONSTRAINT promotion_promotion_rule_pkey PRIMARY KEY (promotion_id, promotion_rule_id);


--
-- Name: promotion_rule promotion_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.promotion_rule
    ADD CONSTRAINT promotion_rule_pkey PRIMARY KEY (id);


--
-- Name: promotion_rule_value promotion_rule_value_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.promotion_rule_value
    ADD CONSTRAINT promotion_rule_value_pkey PRIMARY KEY (id);


--
-- Name: provider_identity provider_identity_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.provider_identity
    ADD CONSTRAINT provider_identity_pkey PRIMARY KEY (id);


--
-- Name: publishable_api_key_sales_channel publishable_api_key_sales_channel_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.publishable_api_key_sales_channel
    ADD CONSTRAINT publishable_api_key_sales_channel_pkey PRIMARY KEY (publishable_key_id, sales_channel_id);


--
-- Name: push_token push_token_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.push_token
    ADD CONSTRAINT push_token_pkey PRIMARY KEY (id);


--
-- Name: refund refund_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.refund
    ADD CONSTRAINT refund_pkey PRIMARY KEY (id);


--
-- Name: refund_reason refund_reason_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.refund_reason
    ADD CONSTRAINT refund_reason_pkey PRIMARY KEY (id);


--
-- Name: region_country region_country_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.region_country
    ADD CONSTRAINT region_country_pkey PRIMARY KEY (iso_2);


--
-- Name: region_payment_provider region_payment_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.region_payment_provider
    ADD CONSTRAINT region_payment_provider_pkey PRIMARY KEY (region_id, payment_provider_id);


--
-- Name: region region_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_pkey PRIMARY KEY (id);


--
-- Name: reservation_item reservation_item_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.reservation_item
    ADD CONSTRAINT reservation_item_pkey PRIMARY KEY (id);


--
-- Name: return_fulfillment return_fulfillment_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.return_fulfillment
    ADD CONSTRAINT return_fulfillment_pkey PRIMARY KEY (return_id, fulfillment_id);


--
-- Name: return_item return_item_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.return_item
    ADD CONSTRAINT return_item_pkey PRIMARY KEY (id);


--
-- Name: return return_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.return
    ADD CONSTRAINT return_pkey PRIMARY KEY (id);


--
-- Name: return_reason return_reason_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.return_reason
    ADD CONSTRAINT return_reason_pkey PRIMARY KEY (id);


--
-- Name: review review_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.review
    ADD CONSTRAINT review_pkey PRIMARY KEY (id);


--
-- Name: sales_channel sales_channel_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.sales_channel
    ADD CONSTRAINT sales_channel_pkey PRIMARY KEY (id);


--
-- Name: sales_channel_stock_location sales_channel_stock_location_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.sales_channel_stock_location
    ADD CONSTRAINT sales_channel_stock_location_pkey PRIMARY KEY (sales_channel_id, stock_location_id);


--
-- Name: script_migrations script_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.script_migrations
    ADD CONSTRAINT script_migrations_pkey PRIMARY KEY (id);


--
-- Name: service_zone service_zone_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.service_zone
    ADD CONSTRAINT service_zone_pkey PRIMARY KEY (id);


--
-- Name: shipping_option shipping_option_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_pkey PRIMARY KEY (id);


--
-- Name: shipping_option_price_set shipping_option_price_set_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.shipping_option_price_set
    ADD CONSTRAINT shipping_option_price_set_pkey PRIMARY KEY (shipping_option_id, price_set_id);


--
-- Name: shipping_option_rule shipping_option_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.shipping_option_rule
    ADD CONSTRAINT shipping_option_rule_pkey PRIMARY KEY (id);


--
-- Name: shipping_option_type shipping_option_type_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.shipping_option_type
    ADD CONSTRAINT shipping_option_type_pkey PRIMARY KEY (id);


--
-- Name: shipping_profile shipping_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.shipping_profile
    ADD CONSTRAINT shipping_profile_pkey PRIMARY KEY (id);


--
-- Name: short_video short_video_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.short_video
    ADD CONSTRAINT short_video_pkey PRIMARY KEY (id);


--
-- Name: stock_location_address stock_location_address_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.stock_location_address
    ADD CONSTRAINT stock_location_address_pkey PRIMARY KEY (id);


--
-- Name: stock_location stock_location_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.stock_location
    ADD CONSTRAINT stock_location_pkey PRIMARY KEY (id);


--
-- Name: store_currency store_currency_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.store_currency
    ADD CONSTRAINT store_currency_pkey PRIMARY KEY (id);


--
-- Name: store_locale store_locale_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.store_locale
    ADD CONSTRAINT store_locale_pkey PRIMARY KEY (id);


--
-- Name: store store_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.store
    ADD CONSTRAINT store_pkey PRIMARY KEY (id);


--
-- Name: tax_provider tax_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.tax_provider
    ADD CONSTRAINT tax_provider_pkey PRIMARY KEY (id);


--
-- Name: tax_rate tax_rate_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.tax_rate
    ADD CONSTRAINT tax_rate_pkey PRIMARY KEY (id);


--
-- Name: tax_rate_rule tax_rate_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.tax_rate_rule
    ADD CONSTRAINT tax_rate_rule_pkey PRIMARY KEY (id);


--
-- Name: tax_region tax_region_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.tax_region
    ADD CONSTRAINT tax_region_pkey PRIMARY KEY (id);


--
-- Name: translation translation_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.translation
    ADD CONSTRAINT translation_pkey PRIMARY KEY (id);


--
-- Name: translation_settings translation_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.translation_settings
    ADD CONSTRAINT translation_settings_pkey PRIMARY KEY (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: user_preference user_preference_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.user_preference
    ADD CONSTRAINT user_preference_pkey PRIMARY KEY (id);


--
-- Name: user_rbac_role user_rbac_role_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.user_rbac_role
    ADD CONSTRAINT user_rbac_role_pkey PRIMARY KEY (user_id, rbac_role_id);


--
-- Name: vendor_admin vendor_admin_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.vendor_admin
    ADD CONSTRAINT vendor_admin_pkey PRIMARY KEY (id);


--
-- Name: vendor vendor_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.vendor
    ADD CONSTRAINT vendor_pkey PRIMARY KEY (id);


--
-- Name: video_comment video_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.video_comment
    ADD CONSTRAINT video_comment_pkey PRIMARY KEY (id);


--
-- Name: video_like video_like_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.video_like
    ADD CONSTRAINT video_like_pkey PRIMARY KEY (id);


--
-- Name: video_save video_save_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.video_save
    ADD CONSTRAINT video_save_pkey PRIMARY KEY (id);


--
-- Name: view_configuration view_configuration_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.view_configuration
    ADD CONSTRAINT view_configuration_pkey PRIMARY KEY (id);


--
-- Name: workflow_execution workflow_execution_pkey; Type: CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.workflow_execution
    ADD CONSTRAINT workflow_execution_pkey PRIMARY KEY (workflow_id, transaction_id, run_id);


--
-- Name: IDX_account_holder_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_account_holder_deleted_at" ON public.account_holder USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_account_holder_id_5cb3a0c0; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_account_holder_id_5cb3a0c0" ON public.customer_account_holder USING btree (account_holder_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_account_holder_provider_id_external_id_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_account_holder_provider_id_external_id_unique" ON public.account_holder USING btree (provider_id, external_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_analytics_event_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_analytics_event_deleted_at" ON public.analytics_event USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_api_key_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_api_key_deleted_at" ON public.api_key USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_api_key_redacted; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_api_key_redacted" ON public.api_key USING btree (redacted) WHERE (deleted_at IS NULL);


--
-- Name: IDX_api_key_revoked_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_api_key_revoked_at" ON public.api_key USING btree (revoked_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_api_key_token_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_api_key_token_unique" ON public.api_key USING btree (token);


--
-- Name: IDX_api_key_type; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_api_key_type" ON public.api_key USING btree (type);


--
-- Name: IDX_app_notification_recipient; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_app_notification_recipient" ON public.app_notification USING btree (recipient_id, is_read, created_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_application_method_allocation; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_application_method_allocation" ON public.promotion_application_method USING btree (allocation);


--
-- Name: IDX_application_method_target_type; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_application_method_target_type" ON public.promotion_application_method USING btree (target_type);


--
-- Name: IDX_application_method_type; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_application_method_type" ON public.promotion_application_method USING btree (type);


--
-- Name: IDX_auth_identity_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_auth_identity_deleted_at" ON public.auth_identity USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_campaign_budget_type; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_campaign_budget_type" ON public.promotion_campaign_budget USING btree (type);


--
-- Name: IDX_capture_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_capture_deleted_at" ON public.capture USING btree (deleted_at);


--
-- Name: IDX_capture_payment_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_capture_payment_id" ON public.capture USING btree (payment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_address_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_cart_address_deleted_at" ON public.cart_address USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_billing_address_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_cart_billing_address_id" ON public.cart USING btree (billing_address_id) WHERE ((deleted_at IS NULL) AND (billing_address_id IS NOT NULL));


--
-- Name: IDX_cart_credit_line_reference_reference_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_cart_credit_line_reference_reference_id" ON public.credit_line USING btree (reference, reference_id) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_currency_code; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_cart_currency_code" ON public.cart USING btree (currency_code);


--
-- Name: IDX_cart_customer_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_cart_customer_id" ON public.cart USING btree (customer_id) WHERE ((deleted_at IS NULL) AND (customer_id IS NOT NULL));


--
-- Name: IDX_cart_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_cart_deleted_at" ON public.cart USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_id_-4a39f6c9; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_cart_id_-4a39f6c9" ON public.cart_payment_collection USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_id_-71069c16; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_cart_id_-71069c16" ON public.order_cart USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_id_-a9d4a70b; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_cart_id_-a9d4a70b" ON public.cart_promotion USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_line_item_adjustment_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_cart_line_item_adjustment_deleted_at" ON public.cart_line_item_adjustment USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_line_item_adjustment_item_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_cart_line_item_adjustment_item_id" ON public.cart_line_item_adjustment USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_line_item_cart_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_cart_line_item_cart_id" ON public.cart_line_item USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_line_item_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_cart_line_item_deleted_at" ON public.cart_line_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_line_item_tax_line_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_cart_line_item_tax_line_deleted_at" ON public.cart_line_item_tax_line USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_line_item_tax_line_item_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_cart_line_item_tax_line_item_id" ON public.cart_line_item_tax_line USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_region_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_cart_region_id" ON public.cart USING btree (region_id) WHERE ((deleted_at IS NULL) AND (region_id IS NOT NULL));


--
-- Name: IDX_cart_sales_channel_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_cart_sales_channel_id" ON public.cart USING btree (sales_channel_id) WHERE ((deleted_at IS NULL) AND (sales_channel_id IS NOT NULL));


--
-- Name: IDX_cart_shipping_address_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_cart_shipping_address_id" ON public.cart USING btree (shipping_address_id) WHERE ((deleted_at IS NULL) AND (shipping_address_id IS NOT NULL));


--
-- Name: IDX_cart_shipping_method_adjustment_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_cart_shipping_method_adjustment_deleted_at" ON public.cart_shipping_method_adjustment USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_shipping_method_adjustment_shipping_method_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_cart_shipping_method_adjustment_shipping_method_id" ON public.cart_shipping_method_adjustment USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_shipping_method_cart_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_cart_shipping_method_cart_id" ON public.cart_shipping_method USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_shipping_method_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_cart_shipping_method_deleted_at" ON public.cart_shipping_method USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_shipping_method_tax_line_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_cart_shipping_method_tax_line_deleted_at" ON public.cart_shipping_method_tax_line USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_shipping_method_tax_line_shipping_method_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_cart_shipping_method_tax_line_shipping_method_id" ON public.cart_shipping_method_tax_line USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_category_handle_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_category_handle_unique" ON public.product_category USING btree (handle) WHERE (deleted_at IS NULL);


--
-- Name: IDX_collection_handle_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_collection_handle_unique" ON public.product_collection USING btree (handle) WHERE (deleted_at IS NULL);


--
-- Name: IDX_conversation_customer_vendor; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_conversation_customer_vendor" ON public.conversation USING btree (customer_id, vendor_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_conversation_customer_vendor_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_conversation_customer_vendor_unique" ON public.conversation USING btree (customer_id, vendor_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_credit_line_cart_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_credit_line_cart_id" ON public.credit_line USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_credit_line_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_credit_line_deleted_at" ON public.credit_line USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_address_customer_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_customer_address_customer_id" ON public.customer_address USING btree (customer_id);


--
-- Name: IDX_customer_address_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_customer_address_deleted_at" ON public.customer_address USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_address_unique_customer_billing; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_customer_address_unique_customer_billing" ON public.customer_address USING btree (customer_id) WHERE (is_default_billing = true);


--
-- Name: IDX_customer_address_unique_customer_shipping; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_customer_address_unique_customer_shipping" ON public.customer_address USING btree (customer_id) WHERE (is_default_shipping = true);


--
-- Name: IDX_customer_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_customer_deleted_at" ON public.customer USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_email_has_account_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_customer_email_has_account_unique" ON public.customer USING btree (email, has_account) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_customer_customer_group_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_customer_group_customer_customer_group_id" ON public.customer_group_customer USING btree (customer_group_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_customer_customer_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_customer_group_customer_customer_id" ON public.customer_group_customer USING btree (customer_id);


--
-- Name: IDX_customer_group_customer_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_customer_group_customer_deleted_at" ON public.customer_group_customer USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_customer_group_deleted_at" ON public.customer_group USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_name_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_customer_group_name_unique" ON public.customer_group USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_id_5cb3a0c0; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_customer_id_5cb3a0c0" ON public.customer_account_holder USING btree (customer_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_payment_method_customer_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_customer_payment_method_customer_id" ON public.customer_payment_method USING btree (customer_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_deleted_at_-12e0822f; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_deleted_at_-12e0822f" ON public.marketplace_vendor_order_order USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-1d67bae40; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_deleted_at_-1d67bae40" ON public.publishable_api_key_sales_channel USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-1e5992737; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_deleted_at_-1e5992737" ON public.location_fulfillment_provider USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-31ea43a; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_deleted_at_-31ea43a" ON public.return_fulfillment USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-4a39f6c9; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_deleted_at_-4a39f6c9" ON public.cart_payment_collection USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-71069c16; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_deleted_at_-71069c16" ON public.order_cart USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-71518339; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_deleted_at_-71518339" ON public.order_promotion USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-a9d4a70b; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_deleted_at_-a9d4a70b" ON public.cart_promotion USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-d14c9099; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_deleted_at_-d14c9099" ON public.marketplace_vendor_promotion_promotion USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-e88adb96; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_deleted_at_-e88adb96" ON public.location_fulfillment_set USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-e8d2543e; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_deleted_at_-e8d2543e" ON public.order_fulfillment USING btree (deleted_at);


--
-- Name: IDX_deleted_at_155848331; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_deleted_at_155848331" ON public.marketplace_vendor_stock_location_stock_location USING btree (deleted_at);


--
-- Name: IDX_deleted_at_17a262437; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_deleted_at_17a262437" ON public.product_shipping_profile USING btree (deleted_at);


--
-- Name: IDX_deleted_at_17b4c4e35; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_deleted_at_17b4c4e35" ON public.product_variant_inventory_item USING btree (deleted_at);


--
-- Name: IDX_deleted_at_1c934dab0; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_deleted_at_1c934dab0" ON public.region_payment_provider USING btree (deleted_at);


--
-- Name: IDX_deleted_at_20b454295; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_deleted_at_20b454295" ON public.product_sales_channel USING btree (deleted_at);


--
-- Name: IDX_deleted_at_227c36b1c; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_deleted_at_227c36b1c" ON public.delivery_delivery_company_fulfillment_shipping_option USING btree (deleted_at);


--
-- Name: IDX_deleted_at_26d06f470; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_deleted_at_26d06f470" ON public.sales_channel_stock_location USING btree (deleted_at);


--
-- Name: IDX_deleted_at_3ca1b85b; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_deleted_at_3ca1b85b" ON public.marketplace_vendor_product_product USING btree (deleted_at);


--
-- Name: IDX_deleted_at_52b23597; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_deleted_at_52b23597" ON public.product_variant_price_set USING btree (deleted_at);


--
-- Name: IDX_deleted_at_5cb3a0c0; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_deleted_at_5cb3a0c0" ON public.customer_account_holder USING btree (deleted_at);


--
-- Name: IDX_deleted_at_64ff0c4c; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_deleted_at_64ff0c4c" ON public.user_rbac_role USING btree (deleted_at);


--
-- Name: IDX_deleted_at_ba32fa9c; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_deleted_at_ba32fa9c" ON public.shipping_option_price_set USING btree (deleted_at);


--
-- Name: IDX_deleted_at_f42b9949; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_deleted_at_f42b9949" ON public.order_payment_collection USING btree (deleted_at);


--
-- Name: IDX_delivery_company_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_delivery_company_deleted_at" ON public.delivery_company USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_delivery_company_email_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_delivery_company_email_unique" ON public.delivery_company USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: IDX_delivery_company_id_227c36b1c; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_delivery_company_id_227c36b1c" ON public.delivery_delivery_company_fulfillment_shipping_option USING btree (delivery_company_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_delivery_driver_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_delivery_driver_deleted_at" ON public.delivery_driver USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_delivery_driver_delivery_company_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_delivery_driver_delivery_company_id" ON public.delivery_driver USING btree (delivery_company_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_address_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_fulfillment_address_deleted_at" ON public.fulfillment_address USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_fulfillment_deleted_at" ON public.fulfillment USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_id_-31ea43a; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_fulfillment_id_-31ea43a" ON public.return_fulfillment USING btree (fulfillment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_id_-e8d2543e; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_fulfillment_id_-e8d2543e" ON public.order_fulfillment USING btree (fulfillment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_item_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_fulfillment_item_deleted_at" ON public.fulfillment_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_item_fulfillment_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_fulfillment_item_fulfillment_id" ON public.fulfillment_item USING btree (fulfillment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_item_inventory_item_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_fulfillment_item_inventory_item_id" ON public.fulfillment_item USING btree (inventory_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_item_line_item_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_fulfillment_item_line_item_id" ON public.fulfillment_item USING btree (line_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_label_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_fulfillment_label_deleted_at" ON public.fulfillment_label USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_label_fulfillment_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_fulfillment_label_fulfillment_id" ON public.fulfillment_label USING btree (fulfillment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_location_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_fulfillment_location_id" ON public.fulfillment USING btree (location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_provider_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_fulfillment_provider_deleted_at" ON public.fulfillment_provider USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_provider_id_-1e5992737; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_fulfillment_provider_id_-1e5992737" ON public.location_fulfillment_provider USING btree (fulfillment_provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_set_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_fulfillment_set_deleted_at" ON public.fulfillment_set USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_set_id_-e88adb96; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_fulfillment_set_id_-e88adb96" ON public.location_fulfillment_set USING btree (fulfillment_set_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_set_name_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_fulfillment_set_name_unique" ON public.fulfillment_set USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_shipping_option_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_fulfillment_shipping_option_id" ON public.fulfillment USING btree (shipping_option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_geo_zone_city; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_geo_zone_city" ON public.geo_zone USING btree (city) WHERE ((deleted_at IS NULL) AND (city IS NOT NULL));


--
-- Name: IDX_geo_zone_country_code; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_geo_zone_country_code" ON public.geo_zone USING btree (country_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_geo_zone_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_geo_zone_deleted_at" ON public.geo_zone USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_geo_zone_province_code; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_geo_zone_province_code" ON public.geo_zone USING btree (province_code) WHERE ((deleted_at IS NULL) AND (province_code IS NOT NULL));


--
-- Name: IDX_geo_zone_service_zone_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_geo_zone_service_zone_id" ON public.geo_zone USING btree (service_zone_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_id_-12e0822f; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_id_-12e0822f" ON public.marketplace_vendor_order_order USING btree (id);


--
-- Name: IDX_id_-1d67bae40; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_id_-1d67bae40" ON public.publishable_api_key_sales_channel USING btree (id);


--
-- Name: IDX_id_-1e5992737; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_id_-1e5992737" ON public.location_fulfillment_provider USING btree (id);


--
-- Name: IDX_id_-31ea43a; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_id_-31ea43a" ON public.return_fulfillment USING btree (id);


--
-- Name: IDX_id_-4a39f6c9; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_id_-4a39f6c9" ON public.cart_payment_collection USING btree (id);


--
-- Name: IDX_id_-71069c16; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_id_-71069c16" ON public.order_cart USING btree (id);


--
-- Name: IDX_id_-71518339; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_id_-71518339" ON public.order_promotion USING btree (id);


--
-- Name: IDX_id_-a9d4a70b; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_id_-a9d4a70b" ON public.cart_promotion USING btree (id);


--
-- Name: IDX_id_-d14c9099; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_id_-d14c9099" ON public.marketplace_vendor_promotion_promotion USING btree (id);


--
-- Name: IDX_id_-e88adb96; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_id_-e88adb96" ON public.location_fulfillment_set USING btree (id);


--
-- Name: IDX_id_-e8d2543e; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_id_-e8d2543e" ON public.order_fulfillment USING btree (id);


--
-- Name: IDX_id_155848331; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_id_155848331" ON public.marketplace_vendor_stock_location_stock_location USING btree (id);


--
-- Name: IDX_id_17a262437; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_id_17a262437" ON public.product_shipping_profile USING btree (id);


--
-- Name: IDX_id_17b4c4e35; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_id_17b4c4e35" ON public.product_variant_inventory_item USING btree (id);


--
-- Name: IDX_id_1c934dab0; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_id_1c934dab0" ON public.region_payment_provider USING btree (id);


--
-- Name: IDX_id_20b454295; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_id_20b454295" ON public.product_sales_channel USING btree (id);


--
-- Name: IDX_id_227c36b1c; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_id_227c36b1c" ON public.delivery_delivery_company_fulfillment_shipping_option USING btree (id);


--
-- Name: IDX_id_26d06f470; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_id_26d06f470" ON public.sales_channel_stock_location USING btree (id);


--
-- Name: IDX_id_3ca1b85b; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_id_3ca1b85b" ON public.marketplace_vendor_product_product USING btree (id);


--
-- Name: IDX_id_52b23597; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_id_52b23597" ON public.product_variant_price_set USING btree (id);


--
-- Name: IDX_id_5cb3a0c0; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_id_5cb3a0c0" ON public.customer_account_holder USING btree (id);


--
-- Name: IDX_id_64ff0c4c; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_id_64ff0c4c" ON public.user_rbac_role USING btree (id);


--
-- Name: IDX_id_ba32fa9c; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_id_ba32fa9c" ON public.shipping_option_price_set USING btree (id);


--
-- Name: IDX_id_f42b9949; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_id_f42b9949" ON public.order_payment_collection USING btree (id);


--
-- Name: IDX_image_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_image_deleted_at" ON public.image USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_image_product_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_image_product_id" ON public.image USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_item_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_inventory_item_deleted_at" ON public.inventory_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_inventory_item_id_17b4c4e35; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_inventory_item_id_17b4c4e35" ON public.product_variant_inventory_item USING btree (inventory_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_item_sku; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_inventory_item_sku" ON public.inventory_item USING btree (sku) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_level_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_inventory_level_deleted_at" ON public.inventory_level USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_inventory_level_inventory_item_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_inventory_level_inventory_item_id" ON public.inventory_level USING btree (inventory_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_level_location_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_inventory_level_location_id" ON public.inventory_level USING btree (location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_level_location_id_inventory_item_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_inventory_level_location_id_inventory_item_id" ON public.inventory_level USING btree (inventory_item_id, location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_invite_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_invite_deleted_at" ON public.invite USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_invite_email_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_invite_email_unique" ON public.invite USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: IDX_invite_token; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_invite_token" ON public.invite USING btree (token) WHERE (deleted_at IS NULL);


--
-- Name: IDX_line_item_adjustment_promotion_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_line_item_adjustment_promotion_id" ON public.cart_line_item_adjustment USING btree (promotion_id) WHERE ((deleted_at IS NULL) AND (promotion_id IS NOT NULL));


--
-- Name: IDX_line_item_product_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_line_item_product_id" ON public.cart_line_item USING btree (product_id) WHERE ((deleted_at IS NULL) AND (product_id IS NOT NULL));


--
-- Name: IDX_line_item_product_type_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_line_item_product_type_id" ON public.order_line_item USING btree (product_type_id) WHERE ((deleted_at IS NULL) AND (product_type_id IS NOT NULL));


--
-- Name: IDX_line_item_tax_line_tax_rate_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_line_item_tax_line_tax_rate_id" ON public.cart_line_item_tax_line USING btree (tax_rate_id) WHERE ((deleted_at IS NULL) AND (tax_rate_id IS NOT NULL));


--
-- Name: IDX_line_item_variant_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_line_item_variant_id" ON public.cart_line_item USING btree (variant_id) WHERE ((deleted_at IS NULL) AND (variant_id IS NOT NULL));


--
-- Name: IDX_locale_code_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_locale_code_unique" ON public.locale USING btree (code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_locale_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_locale_deleted_at" ON public.locale USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_message_conversation_created; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_message_conversation_created" ON public.message USING btree (conversation_id, created_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_message_conversation_is_read; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_message_conversation_is_read" ON public.message USING btree (conversation_id, is_read) WHERE (deleted_at IS NULL);


--
-- Name: IDX_notification_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_notification_deleted_at" ON public.notification USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_notification_idempotency_key_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_notification_idempotency_key_unique" ON public.notification USING btree (idempotency_key) WHERE (deleted_at IS NULL);


--
-- Name: IDX_notification_provider_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_notification_provider_deleted_at" ON public.notification_provider USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_notification_provider_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_notification_provider_id" ON public.notification USING btree (provider_id);


--
-- Name: IDX_notification_receiver_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_notification_receiver_id" ON public.notification USING btree (receiver_id);


--
-- Name: IDX_option_product_id_title_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_option_product_id_title_unique" ON public.product_option USING btree (product_id, title) WHERE (deleted_at IS NULL);


--
-- Name: IDX_option_value_option_id_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_option_value_option_id_unique" ON public.product_option_value USING btree (option_id, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_address_customer_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_address_customer_id" ON public.order_address USING btree (customer_id);


--
-- Name: IDX_order_address_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_address_deleted_at" ON public.order_address USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_billing_address_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_billing_address_id" ON public."order" USING btree (billing_address_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_action_claim_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_change_action_claim_id" ON public.order_change_action USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_action_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_change_action_deleted_at" ON public.order_change_action USING btree (deleted_at);


--
-- Name: IDX_order_change_action_exchange_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_change_action_exchange_id" ON public.order_change_action USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_action_order_change_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_change_action_order_change_id" ON public.order_change_action USING btree (order_change_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_action_order_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_change_action_order_id" ON public.order_change_action USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_action_ordering; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_change_action_ordering" ON public.order_change_action USING btree (ordering) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_action_return_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_change_action_return_id" ON public.order_change_action USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_change_type; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_change_change_type" ON public.order_change USING btree (change_type);


--
-- Name: IDX_order_change_claim_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_change_claim_id" ON public.order_change USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_change_deleted_at" ON public.order_change USING btree (deleted_at);


--
-- Name: IDX_order_change_exchange_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_change_exchange_id" ON public.order_change USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_order_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_change_order_id" ON public.order_change USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_order_id_version; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_change_order_id_version" ON public.order_change USING btree (order_id, version);


--
-- Name: IDX_order_change_return_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_change_return_id" ON public.order_change USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_status; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_change_status" ON public.order_change USING btree (status) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_version; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_change_version" ON public.order_change USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_claim_deleted_at" ON public.order_claim USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_display_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_claim_display_id" ON public.order_claim USING btree (display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_item_claim_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_claim_item_claim_id" ON public.order_claim_item USING btree (claim_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_item_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_claim_item_deleted_at" ON public.order_claim_item USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_item_image_claim_item_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_claim_item_image_claim_item_id" ON public.order_claim_item_image USING btree (claim_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_item_image_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_claim_item_image_deleted_at" ON public.order_claim_item_image USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_claim_item_item_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_claim_item_item_id" ON public.order_claim_item USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_order_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_claim_order_id" ON public.order_claim USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_return_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_claim_return_id" ON public.order_claim USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_credit_line_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_credit_line_deleted_at" ON public.order_credit_line USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_credit_line_order_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_credit_line_order_id" ON public.order_credit_line USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_credit_line_order_id_version; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_credit_line_order_id_version" ON public.order_credit_line USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_currency_code; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_currency_code" ON public."order" USING btree (currency_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_custom_display_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_order_custom_display_id" ON public."order" USING btree (custom_display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_customer_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_customer_id" ON public."order" USING btree (customer_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_deleted_at" ON public."order" USING btree (deleted_at);


--
-- Name: IDX_order_display_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_display_id" ON public."order" USING btree (display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_exchange_deleted_at" ON public.order_exchange USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_display_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_exchange_display_id" ON public.order_exchange USING btree (display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_item_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_exchange_item_deleted_at" ON public.order_exchange_item USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_item_exchange_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_exchange_item_exchange_id" ON public.order_exchange_item USING btree (exchange_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_item_item_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_exchange_item_item_id" ON public.order_exchange_item USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_order_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_exchange_order_id" ON public.order_exchange USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_return_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_exchange_return_id" ON public.order_exchange USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_id_-12e0822f; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_id_-12e0822f" ON public.marketplace_vendor_order_order USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_id_-71069c16; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_id_-71069c16" ON public.order_cart USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_id_-71518339; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_id_-71518339" ON public.order_promotion USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_id_-e8d2543e; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_id_-e8d2543e" ON public.order_fulfillment USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_id_f42b9949; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_id_f42b9949" ON public.order_payment_collection USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_is_draft_order; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_is_draft_order" ON public."order" USING btree (is_draft_order) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_item_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_item_deleted_at" ON public.order_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_item_item_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_item_item_id" ON public.order_item USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_item_order_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_item_order_id" ON public.order_item USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_item_order_id_version; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_item_order_id_version" ON public.order_item USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_line_item_adjustment_item_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_line_item_adjustment_item_id" ON public.order_line_item_adjustment USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_line_item_product_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_line_item_product_id" ON public.order_line_item USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_line_item_tax_line_item_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_line_item_tax_line_item_id" ON public.order_line_item_tax_line USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_line_item_variant_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_line_item_variant_id" ON public.order_line_item USING btree (variant_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_region_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_region_id" ON public."order" USING btree (region_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_sales_channel_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_sales_channel_id" ON public."order" USING btree (sales_channel_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_address_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_shipping_address_id" ON public."order" USING btree (shipping_address_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_claim_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_shipping_claim_id" ON public.order_shipping USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_shipping_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_shipping_deleted_at" ON public.order_shipping USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_shipping_exchange_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_shipping_exchange_id" ON public.order_shipping USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_shipping_item_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_shipping_item_id" ON public.order_shipping USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_method_adjustment_shipping_method_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_shipping_method_adjustment_shipping_method_id" ON public.order_shipping_method_adjustment USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_method_shipping_option_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_shipping_method_shipping_option_id" ON public.order_shipping_method USING btree (shipping_option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_method_tax_line_shipping_method_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_shipping_method_tax_line_shipping_method_id" ON public.order_shipping_method_tax_line USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_order_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_shipping_order_id" ON public.order_shipping USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_order_id_version; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_shipping_order_id_version" ON public.order_shipping USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_return_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_shipping_return_id" ON public.order_shipping USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_shipping_shipping_method_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_shipping_shipping_method_id" ON public.order_shipping USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_summary_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_summary_deleted_at" ON public.order_summary USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_summary_order_id_version; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_summary_order_id_version" ON public.order_summary USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_claim_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_transaction_claim_id" ON public.order_transaction USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_transaction_currency_code; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_transaction_currency_code" ON public.order_transaction USING btree (currency_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_exchange_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_transaction_exchange_id" ON public.order_transaction USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_transaction_order_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_transaction_order_id" ON public.order_transaction USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_order_id_version; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_transaction_order_id_version" ON public.order_transaction USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_reference_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_transaction_reference_id" ON public.order_transaction USING btree (reference_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_return_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_order_transaction_return_id" ON public.order_transaction USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_payment_collection_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_payment_collection_deleted_at" ON public.payment_collection USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_payment_collection_id_-4a39f6c9; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_payment_collection_id_-4a39f6c9" ON public.cart_payment_collection USING btree (payment_collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_collection_id_f42b9949; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_payment_collection_id_f42b9949" ON public.order_payment_collection USING btree (payment_collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_payment_deleted_at" ON public.payment USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_payment_payment_collection_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_payment_payment_collection_id" ON public.payment USING btree (payment_collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_payment_session_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_payment_payment_session_id" ON public.payment USING btree (payment_session_id);


--
-- Name: IDX_payment_payment_session_id_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_payment_payment_session_id_unique" ON public.payment USING btree (payment_session_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_provider_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_payment_provider_deleted_at" ON public.payment_provider USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_provider_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_payment_provider_id" ON public.payment USING btree (provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_provider_id_1c934dab0; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_payment_provider_id_1c934dab0" ON public.region_payment_provider USING btree (payment_provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_session_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_payment_session_deleted_at" ON public.payment_session USING btree (deleted_at);


--
-- Name: IDX_payment_session_payment_collection_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_payment_session_payment_collection_id" ON public.payment_session USING btree (payment_collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_currency_code; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_price_currency_code" ON public.price USING btree (currency_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_price_deleted_at" ON public.price USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_list_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_price_list_deleted_at" ON public.price_list USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_list_id_status_starts_at_ends_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_price_list_id_status_starts_at_ends_at" ON public.price_list USING btree (id, status, starts_at, ends_at) WHERE ((deleted_at IS NULL) AND (status = 'active'::text));


--
-- Name: IDX_price_list_rule_attribute; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_price_list_rule_attribute" ON public.price_list_rule USING btree (attribute) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_list_rule_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_price_list_rule_deleted_at" ON public.price_list_rule USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_list_rule_price_list_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_price_list_rule_price_list_id" ON public.price_list_rule USING btree (price_list_id) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_list_rule_value; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_price_list_rule_value" ON public.price_list_rule USING gin (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_preference_attribute_value; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_price_preference_attribute_value" ON public.price_preference USING btree (attribute, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_preference_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_price_preference_deleted_at" ON public.price_preference USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_price_list_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_price_price_list_id" ON public.price USING btree (price_list_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_price_set_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_price_price_set_id" ON public.price USING btree (price_set_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_attribute; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_price_rule_attribute" ON public.price_rule USING btree (attribute) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_attribute_value; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_price_rule_attribute_value" ON public.price_rule USING btree (attribute, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_attribute_value_price_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_price_rule_attribute_value_price_id" ON public.price_rule USING btree (attribute, value, price_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_price_rule_deleted_at" ON public.price_rule USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_rule_operator; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_price_rule_operator" ON public.price_rule USING btree (operator);


--
-- Name: IDX_price_rule_operator_value; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_price_rule_operator_value" ON public.price_rule USING btree (operator, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_price_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_price_rule_price_id" ON public.price_rule USING btree (price_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_price_id_attribute_operator_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_price_rule_price_id_attribute_operator_unique" ON public.price_rule USING btree (price_id, attribute, operator) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_set_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_price_set_deleted_at" ON public.price_set USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_set_id_52b23597; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_price_set_id_52b23597" ON public.product_variant_price_set USING btree (price_set_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_set_id_ba32fa9c; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_price_set_id_ba32fa9c" ON public.shipping_option_price_set USING btree (price_set_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_category_parent_category_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_category_parent_category_id" ON public.product_category USING btree (parent_category_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_category_path; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_category_path" ON public.product_category USING btree (mpath) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_collection_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_collection_deleted_at" ON public.product_collection USING btree (deleted_at);


--
-- Name: IDX_product_collection_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_collection_id" ON public.product USING btree (collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_deleted_at" ON public.product USING btree (deleted_at);


--
-- Name: IDX_product_handle_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_product_handle_unique" ON public.product USING btree (handle) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_id_17a262437; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_id_17a262437" ON public.product_shipping_profile USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_id_20b454295; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_id_20b454295" ON public.product_sales_channel USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_id_3ca1b85b; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_id_3ca1b85b" ON public.marketplace_vendor_product_product USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_image_rank; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_image_rank" ON public.image USING btree (rank) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_image_rank_product_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_image_rank_product_id" ON public.image USING btree (rank, product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_image_url; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_image_url" ON public.image USING btree (url) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_image_url_rank_product_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_image_url_rank_product_id" ON public.image USING btree (url, rank, product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_option_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_option_deleted_at" ON public.product_option USING btree (deleted_at);


--
-- Name: IDX_product_option_product_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_option_product_id" ON public.product_option USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_option_value_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_option_value_deleted_at" ON public.product_option_value USING btree (deleted_at);


--
-- Name: IDX_product_option_value_option_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_option_value_option_id" ON public.product_option_value USING btree (option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_status; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_status" ON public.product USING btree (status) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_tag_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_tag_deleted_at" ON public.product_tag USING btree (deleted_at);


--
-- Name: IDX_product_type_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_type_deleted_at" ON public.product_type USING btree (deleted_at);


--
-- Name: IDX_product_type_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_type_id" ON public.product USING btree (type_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_barcode_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_product_variant_barcode_unique" ON public.product_variant USING btree (barcode) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_variant_deleted_at" ON public.product_variant USING btree (deleted_at);


--
-- Name: IDX_product_variant_ean_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_product_variant_ean_unique" ON public.product_variant USING btree (ean) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_id_product_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_variant_id_product_id" ON public.product_variant USING btree (id, product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_product_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_variant_product_id" ON public.product_variant USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_product_image_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_variant_product_image_deleted_at" ON public.product_variant_product_image USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_product_image_image_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_variant_product_image_image_id" ON public.product_variant_product_image USING btree (image_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_product_image_variant_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_product_variant_product_image_variant_id" ON public.product_variant_product_image USING btree (variant_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_sku_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_product_variant_sku_unique" ON public.product_variant USING btree (sku) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_upc_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_product_variant_upc_unique" ON public.product_variant USING btree (upc) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_application_method_currency_code; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_promotion_application_method_currency_code" ON public.promotion_application_method USING btree (currency_code) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_promotion_application_method_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_promotion_application_method_deleted_at" ON public.promotion_application_method USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_application_method_promotion_id_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_promotion_application_method_promotion_id_unique" ON public.promotion_application_method USING btree (promotion_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_budget_campaign_id_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_promotion_campaign_budget_campaign_id_unique" ON public.promotion_campaign_budget USING btree (campaign_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_budget_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_promotion_campaign_budget_deleted_at" ON public.promotion_campaign_budget USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_budget_usage_attribute_value_budget_id_u; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_promotion_campaign_budget_usage_attribute_value_budget_id_u" ON public.promotion_campaign_budget_usage USING btree (attribute_value, budget_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_budget_usage_budget_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_promotion_campaign_budget_usage_budget_id" ON public.promotion_campaign_budget_usage USING btree (budget_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_budget_usage_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_promotion_campaign_budget_usage_deleted_at" ON public.promotion_campaign_budget_usage USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_campaign_identifier_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_promotion_campaign_campaign_identifier_unique" ON public.promotion_campaign USING btree (campaign_identifier) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_promotion_campaign_deleted_at" ON public.promotion_campaign USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_promotion_campaign_id" ON public.promotion USING btree (campaign_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_promotion_deleted_at" ON public.promotion USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_id_-71518339; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_promotion_id_-71518339" ON public.order_promotion USING btree (promotion_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_id_-a9d4a70b; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_promotion_id_-a9d4a70b" ON public.cart_promotion USING btree (promotion_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_id_-d14c9099; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_promotion_id_-d14c9099" ON public.marketplace_vendor_promotion_promotion USING btree (promotion_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_is_automatic; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_promotion_is_automatic" ON public.promotion USING btree (is_automatic) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_attribute; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_promotion_rule_attribute" ON public.promotion_rule USING btree (attribute);


--
-- Name: IDX_promotion_rule_attribute_operator; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_promotion_rule_attribute_operator" ON public.promotion_rule USING btree (attribute, operator) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_attribute_operator_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_promotion_rule_attribute_operator_id" ON public.promotion_rule USING btree (operator, attribute, id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_promotion_rule_deleted_at" ON public.promotion_rule USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_operator; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_promotion_rule_operator" ON public.promotion_rule USING btree (operator);


--
-- Name: IDX_promotion_rule_value_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_promotion_rule_value_deleted_at" ON public.promotion_rule_value USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_value_promotion_rule_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_promotion_rule_value_promotion_rule_id" ON public.promotion_rule_value USING btree (promotion_rule_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_value_rule_id_value; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_promotion_rule_value_rule_id_value" ON public.promotion_rule_value USING btree (promotion_rule_id, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_value_value; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_promotion_rule_value_value" ON public.promotion_rule_value USING btree (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_status; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_promotion_status" ON public.promotion USING btree (status) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_type; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_promotion_type" ON public.promotion USING btree (type);


--
-- Name: IDX_provider_identity_auth_identity_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_provider_identity_auth_identity_id" ON public.provider_identity USING btree (auth_identity_id);


--
-- Name: IDX_provider_identity_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_provider_identity_deleted_at" ON public.provider_identity USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_provider_identity_provider_entity_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_provider_identity_provider_entity_id" ON public.provider_identity USING btree (entity_id, provider);


--
-- Name: IDX_publishable_key_id_-1d67bae40; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_publishable_key_id_-1d67bae40" ON public.publishable_api_key_sales_channel USING btree (publishable_key_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_push_token_recipient_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_push_token_recipient_id" ON public.push_token USING btree (recipient_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_rbac_role_id_64ff0c4c; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_rbac_role_id_64ff0c4c" ON public.user_rbac_role USING btree (rbac_role_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_refund_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_refund_deleted_at" ON public.refund USING btree (deleted_at);


--
-- Name: IDX_refund_payment_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_refund_payment_id" ON public.refund USING btree (payment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_refund_reason_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_refund_reason_deleted_at" ON public.refund_reason USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_refund_refund_reason_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_refund_refund_reason_id" ON public.refund USING btree (refund_reason_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_region_country_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_region_country_deleted_at" ON public.region_country USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_region_country_region_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_region_country_region_id" ON public.region_country USING btree (region_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_region_country_region_id_iso_2_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_region_country_region_id_iso_2_unique" ON public.region_country USING btree (region_id, iso_2);


--
-- Name: IDX_region_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_region_deleted_at" ON public.region USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_region_id_1c934dab0; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_region_id_1c934dab0" ON public.region_payment_provider USING btree (region_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_reservation_item_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_reservation_item_deleted_at" ON public.reservation_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_reservation_item_inventory_item_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_reservation_item_inventory_item_id" ON public.reservation_item USING btree (inventory_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_reservation_item_line_item_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_reservation_item_line_item_id" ON public.reservation_item USING btree (line_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_reservation_item_location_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_reservation_item_location_id" ON public.reservation_item USING btree (location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_claim_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_return_claim_id" ON public.return USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_return_display_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_return_display_id" ON public.return USING btree (display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_exchange_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_return_exchange_id" ON public.return USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_return_id_-31ea43a; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_return_id_-31ea43a" ON public.return_fulfillment USING btree (return_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_item_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_return_item_deleted_at" ON public.return_item USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_item_item_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_return_item_item_id" ON public.return_item USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_item_reason_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_return_item_reason_id" ON public.return_item USING btree (reason_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_item_return_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_return_item_return_id" ON public.return_item USING btree (return_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_order_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_return_order_id" ON public.return USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_reason_parent_return_reason_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_return_reason_parent_return_reason_id" ON public.return_reason USING btree (parent_return_reason_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_reason_value; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_return_reason_value" ON public.return_reason USING btree (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_review_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_review_deleted_at" ON public.review USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_sales_channel_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_sales_channel_deleted_at" ON public.sales_channel USING btree (deleted_at);


--
-- Name: IDX_sales_channel_id_-1d67bae40; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_sales_channel_id_-1d67bae40" ON public.publishable_api_key_sales_channel USING btree (sales_channel_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_sales_channel_id_20b454295; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_sales_channel_id_20b454295" ON public.product_sales_channel USING btree (sales_channel_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_sales_channel_id_26d06f470; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_sales_channel_id_26d06f470" ON public.sales_channel_stock_location USING btree (sales_channel_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_service_zone_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_service_zone_deleted_at" ON public.service_zone USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_service_zone_fulfillment_set_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_service_zone_fulfillment_set_id" ON public.service_zone USING btree (fulfillment_set_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_service_zone_name_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_service_zone_name_unique" ON public.service_zone USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_method_adjustment_promotion_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_shipping_method_adjustment_promotion_id" ON public.cart_shipping_method_adjustment USING btree (promotion_id) WHERE ((deleted_at IS NULL) AND (promotion_id IS NOT NULL));


--
-- Name: IDX_shipping_method_option_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_shipping_method_option_id" ON public.cart_shipping_method USING btree (shipping_option_id) WHERE ((deleted_at IS NULL) AND (shipping_option_id IS NOT NULL));


--
-- Name: IDX_shipping_method_tax_line_tax_rate_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_shipping_method_tax_line_tax_rate_id" ON public.cart_shipping_method_tax_line USING btree (tax_rate_id) WHERE ((deleted_at IS NULL) AND (tax_rate_id IS NOT NULL));


--
-- Name: IDX_shipping_option_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_shipping_option_deleted_at" ON public.shipping_option USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_shipping_option_id_227c36b1c; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_shipping_option_id_227c36b1c" ON public.delivery_delivery_company_fulfillment_shipping_option USING btree (shipping_option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_id_ba32fa9c; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_shipping_option_id_ba32fa9c" ON public.shipping_option_price_set USING btree (shipping_option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_provider_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_shipping_option_provider_id" ON public.shipping_option USING btree (provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_rule_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_shipping_option_rule_deleted_at" ON public.shipping_option_rule USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_shipping_option_rule_shipping_option_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_shipping_option_rule_shipping_option_id" ON public.shipping_option_rule USING btree (shipping_option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_service_zone_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_shipping_option_service_zone_id" ON public.shipping_option USING btree (service_zone_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_shipping_option_type_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_shipping_option_shipping_option_type_id" ON public.shipping_option USING btree (shipping_option_type_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_shipping_profile_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_shipping_option_shipping_profile_id" ON public.shipping_option USING btree (shipping_profile_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_type_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_shipping_option_type_deleted_at" ON public.shipping_option_type USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_shipping_profile_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_shipping_profile_deleted_at" ON public.shipping_profile USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_shipping_profile_id_17a262437; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_shipping_profile_id_17a262437" ON public.product_shipping_profile USING btree (shipping_profile_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_profile_name_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_shipping_profile_name_unique" ON public.shipping_profile USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_short_video_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_short_video_deleted_at" ON public.short_video USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_short_video_feed; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_short_video_feed" ON public.short_video USING btree (status, created_at DESC) WHERE (deleted_at IS NULL);


--
-- Name: IDX_short_video_vendor_status; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_short_video_vendor_status" ON public.short_video USING btree (vendor_id, status) WHERE (deleted_at IS NULL);


--
-- Name: IDX_single_default_region; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_single_default_region" ON public.tax_rate USING btree (tax_region_id) WHERE ((is_default = true) AND (deleted_at IS NULL));


--
-- Name: IDX_stock_location_address_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_stock_location_address_deleted_at" ON public.stock_location_address USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_stock_location_address_id_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_stock_location_address_id_unique" ON public.stock_location USING btree (address_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_stock_location_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_stock_location_deleted_at" ON public.stock_location USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_stock_location_id_-1e5992737; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_stock_location_id_-1e5992737" ON public.location_fulfillment_provider USING btree (stock_location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_stock_location_id_-e88adb96; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_stock_location_id_-e88adb96" ON public.location_fulfillment_set USING btree (stock_location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_stock_location_id_155848331; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_stock_location_id_155848331" ON public.marketplace_vendor_stock_location_stock_location USING btree (stock_location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_stock_location_id_26d06f470; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_stock_location_id_26d06f470" ON public.sales_channel_stock_location USING btree (stock_location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_store_currency_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_store_currency_deleted_at" ON public.store_currency USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_store_currency_store_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_store_currency_store_id" ON public.store_currency USING btree (store_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_store_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_store_deleted_at" ON public.store USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_store_locale_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_store_locale_deleted_at" ON public.store_locale USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_store_locale_store_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_store_locale_store_id" ON public.store_locale USING btree (store_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tag_value_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_tag_value_unique" ON public.product_tag USING btree (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_provider_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_tax_provider_deleted_at" ON public.tax_provider USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_rate_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_tax_rate_deleted_at" ON public.tax_rate USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_tax_rate_rule_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_tax_rate_rule_deleted_at" ON public.tax_rate_rule USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_tax_rate_rule_reference_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_tax_rate_rule_reference_id" ON public.tax_rate_rule USING btree (reference_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_rate_rule_tax_rate_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_tax_rate_rule_tax_rate_id" ON public.tax_rate_rule USING btree (tax_rate_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_rate_rule_unique_rate_reference; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_tax_rate_rule_unique_rate_reference" ON public.tax_rate_rule USING btree (tax_rate_id, reference_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_rate_tax_region_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_tax_rate_tax_region_id" ON public.tax_rate USING btree (tax_region_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_region_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_tax_region_deleted_at" ON public.tax_region USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_tax_region_parent_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_tax_region_parent_id" ON public.tax_region USING btree (parent_id);


--
-- Name: IDX_tax_region_provider_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_tax_region_provider_id" ON public.tax_region USING btree (provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_region_unique_country_nullable_province; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_tax_region_unique_country_nullable_province" ON public.tax_region USING btree (country_code) WHERE ((province_code IS NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_tax_region_unique_country_province; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_tax_region_unique_country_province" ON public.tax_region USING btree (country_code, province_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_translation_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_translation_deleted_at" ON public.translation USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_translation_locale_code; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_translation_locale_code" ON public.translation USING btree (locale_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_translation_reference_id_locale_code_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_translation_reference_id_locale_code_unique" ON public.translation USING btree (reference_id, locale_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_translation_reference_id_reference; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_translation_reference_id_reference" ON public.translation USING btree (reference_id, reference) WHERE (deleted_at IS NULL);


--
-- Name: IDX_translation_reference_id_reference_locale_code; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_translation_reference_id_reference_locale_code" ON public.translation USING btree (reference_id, reference, locale_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_translation_reference_locale_code; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_translation_reference_locale_code" ON public.translation USING btree (reference, locale_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_translation_settings_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_translation_settings_deleted_at" ON public.translation_settings USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_translation_settings_entity_type_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_translation_settings_entity_type_unique" ON public.translation_settings USING btree (entity_type) WHERE (deleted_at IS NULL);


--
-- Name: IDX_type_value_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_type_value_unique" ON public.product_type USING btree (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_unique_promotion_code; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_unique_promotion_code" ON public.promotion USING btree (code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_user_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_user_deleted_at" ON public."user" USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_user_email_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_user_email_unique" ON public."user" USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: IDX_user_id_64ff0c4c; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_user_id_64ff0c4c" ON public.user_rbac_role USING btree (user_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_user_preference_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_user_preference_deleted_at" ON public.user_preference USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_user_preference_user_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_user_preference_user_id" ON public.user_preference USING btree (user_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_user_preference_user_id_key_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_user_preference_user_id_key_unique" ON public.user_preference USING btree (user_id, key) WHERE (deleted_at IS NULL);


--
-- Name: IDX_variant_id_17b4c4e35; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_variant_id_17b4c4e35" ON public.product_variant_inventory_item USING btree (variant_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_variant_id_52b23597; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_variant_id_52b23597" ON public.product_variant_price_set USING btree (variant_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_vendor_admin_email_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_vendor_admin_email_unique" ON public.vendor_admin USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: IDX_vendor_admin_vendor_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_vendor_admin_vendor_id" ON public.vendor_admin USING btree (vendor_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_vendor_handle_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_vendor_handle_unique" ON public.vendor USING btree (handle) WHERE (deleted_at IS NULL);


--
-- Name: IDX_vendor_id_-12e0822f; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_vendor_id_-12e0822f" ON public.marketplace_vendor_order_order USING btree (vendor_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_vendor_id_-d14c9099; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_vendor_id_-d14c9099" ON public.marketplace_vendor_promotion_promotion USING btree (vendor_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_vendor_id_155848331; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_vendor_id_155848331" ON public.marketplace_vendor_stock_location_stock_location USING btree (vendor_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_vendor_id_3ca1b85b; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_vendor_id_3ca1b85b" ON public.marketplace_vendor_product_product USING btree (vendor_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_video_comment_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_video_comment_deleted_at" ON public.video_comment USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_video_comment_video; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_video_comment_video" ON public.video_comment USING btree (video_id, created_at DESC) WHERE (deleted_at IS NULL);


--
-- Name: IDX_video_like_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_video_like_deleted_at" ON public.video_like USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_video_like_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_video_like_unique" ON public.video_like USING btree (video_id, customer_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_video_save_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_video_save_deleted_at" ON public.video_save USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_video_save_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_video_save_unique" ON public.video_save USING btree (video_id, customer_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_view_configuration_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_view_configuration_deleted_at" ON public.view_configuration USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_view_configuration_entity_is_system_default; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_view_configuration_entity_is_system_default" ON public.view_configuration USING btree (entity, is_system_default) WHERE (deleted_at IS NULL);


--
-- Name: IDX_view_configuration_entity_user_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_view_configuration_entity_user_id" ON public.view_configuration USING btree (entity, user_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_view_configuration_user_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_view_configuration_user_id" ON public.view_configuration USING btree (user_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_deleted_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_workflow_execution_deleted_at" ON public.workflow_execution USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_workflow_execution_id" ON public.workflow_execution USING btree (id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_retention_time_updated_at_state; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_workflow_execution_retention_time_updated_at_state" ON public.workflow_execution USING btree (retention_time, updated_at, state) WHERE ((deleted_at IS NULL) AND (retention_time IS NOT NULL));


--
-- Name: IDX_workflow_execution_run_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_workflow_execution_run_id" ON public.workflow_execution USING btree (run_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_state; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_workflow_execution_state" ON public.workflow_execution USING btree (state) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_state_updated_at; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_workflow_execution_state_updated_at" ON public.workflow_execution USING btree (state, updated_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_transaction_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_workflow_execution_transaction_id" ON public.workflow_execution USING btree (transaction_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_updated_at_retention_time; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_workflow_execution_updated_at_retention_time" ON public.workflow_execution USING btree (updated_at, retention_time) WHERE ((deleted_at IS NULL) AND (retention_time IS NOT NULL) AND ((state)::text = ANY ((ARRAY['done'::character varying, 'failed'::character varying, 'reverted'::character varying])::text[])));


--
-- Name: IDX_workflow_execution_workflow_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_workflow_execution_workflow_id" ON public.workflow_execution USING btree (workflow_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_workflow_id_transaction_id; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE INDEX "IDX_workflow_execution_workflow_id_transaction_id" ON public.workflow_execution USING btree (workflow_id, transaction_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_workflow_id_transaction_id_run_id_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX "IDX_workflow_execution_workflow_id_transaction_id_run_id_unique" ON public.workflow_execution USING btree (workflow_id, transaction_id, run_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_script_name_unique; Type: INDEX; Schema: public; Owner: princelulinda
--

CREATE UNIQUE INDEX idx_script_name_unique ON public.script_migrations USING btree (script_name);


--
-- Name: tax_rate_rule FK_tax_rate_rule_tax_rate_id; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.tax_rate_rule
    ADD CONSTRAINT "FK_tax_rate_rule_tax_rate_id" FOREIGN KEY (tax_rate_id) REFERENCES public.tax_rate(id) ON DELETE CASCADE;


--
-- Name: tax_rate FK_tax_rate_tax_region_id; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.tax_rate
    ADD CONSTRAINT "FK_tax_rate_tax_region_id" FOREIGN KEY (tax_region_id) REFERENCES public.tax_region(id) ON DELETE CASCADE;


--
-- Name: tax_region FK_tax_region_parent_id; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.tax_region
    ADD CONSTRAINT "FK_tax_region_parent_id" FOREIGN KEY (parent_id) REFERENCES public.tax_region(id) ON DELETE CASCADE;


--
-- Name: tax_region FK_tax_region_provider_id; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.tax_region
    ADD CONSTRAINT "FK_tax_region_provider_id" FOREIGN KEY (provider_id) REFERENCES public.tax_provider(id) ON DELETE SET NULL;


--
-- Name: application_method_buy_rules application_method_buy_rules_application_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.application_method_buy_rules
    ADD CONSTRAINT application_method_buy_rules_application_method_id_foreign FOREIGN KEY (application_method_id) REFERENCES public.promotion_application_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: application_method_buy_rules application_method_buy_rules_promotion_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.application_method_buy_rules
    ADD CONSTRAINT application_method_buy_rules_promotion_rule_id_foreign FOREIGN KEY (promotion_rule_id) REFERENCES public.promotion_rule(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: application_method_target_rules application_method_target_rules_application_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.application_method_target_rules
    ADD CONSTRAINT application_method_target_rules_application_method_id_foreign FOREIGN KEY (application_method_id) REFERENCES public.promotion_application_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: application_method_target_rules application_method_target_rules_promotion_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.application_method_target_rules
    ADD CONSTRAINT application_method_target_rules_promotion_rule_id_foreign FOREIGN KEY (promotion_rule_id) REFERENCES public.promotion_rule(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: capture capture_payment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.capture
    ADD CONSTRAINT capture_payment_id_foreign FOREIGN KEY (payment_id) REFERENCES public.payment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart cart_billing_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_billing_address_id_foreign FOREIGN KEY (billing_address_id) REFERENCES public.cart_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: cart_line_item_adjustment cart_line_item_adjustment_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.cart_line_item_adjustment
    ADD CONSTRAINT cart_line_item_adjustment_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.cart_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_line_item cart_line_item_cart_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.cart_line_item
    ADD CONSTRAINT cart_line_item_cart_id_foreign FOREIGN KEY (cart_id) REFERENCES public.cart(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_line_item_tax_line cart_line_item_tax_line_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.cart_line_item_tax_line
    ADD CONSTRAINT cart_line_item_tax_line_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.cart_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart cart_shipping_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_shipping_address_id_foreign FOREIGN KEY (shipping_address_id) REFERENCES public.cart_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: cart_shipping_method_adjustment cart_shipping_method_adjustment_shipping_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.cart_shipping_method_adjustment
    ADD CONSTRAINT cart_shipping_method_adjustment_shipping_method_id_foreign FOREIGN KEY (shipping_method_id) REFERENCES public.cart_shipping_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_shipping_method cart_shipping_method_cart_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.cart_shipping_method
    ADD CONSTRAINT cart_shipping_method_cart_id_foreign FOREIGN KEY (cart_id) REFERENCES public.cart(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_shipping_method_tax_line cart_shipping_method_tax_line_shipping_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.cart_shipping_method_tax_line
    ADD CONSTRAINT cart_shipping_method_tax_line_shipping_method_id_foreign FOREIGN KEY (shipping_method_id) REFERENCES public.cart_shipping_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: credit_line credit_line_cart_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.credit_line
    ADD CONSTRAINT credit_line_cart_id_foreign FOREIGN KEY (cart_id) REFERENCES public.cart(id) ON UPDATE CASCADE;


--
-- Name: customer_address customer_address_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.customer_address
    ADD CONSTRAINT customer_address_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customer(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customer_group_customer customer_group_customer_customer_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.customer_group_customer
    ADD CONSTRAINT customer_group_customer_customer_group_id_foreign FOREIGN KEY (customer_group_id) REFERENCES public.customer_group(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customer_group_customer customer_group_customer_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.customer_group_customer
    ADD CONSTRAINT customer_group_customer_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customer(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: delivery_driver delivery_driver_delivery_company_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.delivery_driver
    ADD CONSTRAINT delivery_driver_delivery_company_id_foreign FOREIGN KEY (delivery_company_id) REFERENCES public.delivery_company(id) ON UPDATE CASCADE;


--
-- Name: fulfillment fulfillment_delivery_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT fulfillment_delivery_address_id_foreign FOREIGN KEY (delivery_address_id) REFERENCES public.fulfillment_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: fulfillment_item fulfillment_item_fulfillment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.fulfillment_item
    ADD CONSTRAINT fulfillment_item_fulfillment_id_foreign FOREIGN KEY (fulfillment_id) REFERENCES public.fulfillment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fulfillment_label fulfillment_label_fulfillment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.fulfillment_label
    ADD CONSTRAINT fulfillment_label_fulfillment_id_foreign FOREIGN KEY (fulfillment_id) REFERENCES public.fulfillment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fulfillment fulfillment_provider_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT fulfillment_provider_id_foreign FOREIGN KEY (provider_id) REFERENCES public.fulfillment_provider(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: fulfillment fulfillment_shipping_option_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT fulfillment_shipping_option_id_foreign FOREIGN KEY (shipping_option_id) REFERENCES public.shipping_option(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: geo_zone geo_zone_service_zone_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.geo_zone
    ADD CONSTRAINT geo_zone_service_zone_id_foreign FOREIGN KEY (service_zone_id) REFERENCES public.service_zone(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: image image_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: inventory_level inventory_level_inventory_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.inventory_level
    ADD CONSTRAINT inventory_level_inventory_item_id_foreign FOREIGN KEY (inventory_item_id) REFERENCES public.inventory_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: message message_conversation_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.message
    ADD CONSTRAINT message_conversation_id_foreign FOREIGN KEY (conversation_id) REFERENCES public.conversation(id) ON UPDATE CASCADE;


--
-- Name: notification notification_provider_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_provider_id_foreign FOREIGN KEY (provider_id) REFERENCES public.notification_provider(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: order order_billing_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_billing_address_id_foreign FOREIGN KEY (billing_address_id) REFERENCES public.order_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: order_change_action order_change_action_order_change_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_change_action
    ADD CONSTRAINT order_change_action_order_change_id_foreign FOREIGN KEY (order_change_id) REFERENCES public.order_change(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_change order_change_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_change
    ADD CONSTRAINT order_change_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_credit_line order_credit_line_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_credit_line
    ADD CONSTRAINT order_credit_line_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_item order_item_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.order_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_item order_item_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_line_item_adjustment order_line_item_adjustment_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_line_item_adjustment
    ADD CONSTRAINT order_line_item_adjustment_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.order_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_line_item_tax_line order_line_item_tax_line_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_line_item_tax_line
    ADD CONSTRAINT order_line_item_tax_line_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.order_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_line_item order_line_item_totals_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_line_item
    ADD CONSTRAINT order_line_item_totals_id_foreign FOREIGN KEY (totals_id) REFERENCES public.order_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order order_shipping_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_shipping_address_id_foreign FOREIGN KEY (shipping_address_id) REFERENCES public.order_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: order_shipping_method_adjustment order_shipping_method_adjustment_shipping_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_shipping_method_adjustment
    ADD CONSTRAINT order_shipping_method_adjustment_shipping_method_id_foreign FOREIGN KEY (shipping_method_id) REFERENCES public.order_shipping_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_shipping_method_tax_line order_shipping_method_tax_line_shipping_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_shipping_method_tax_line
    ADD CONSTRAINT order_shipping_method_tax_line_shipping_method_id_foreign FOREIGN KEY (shipping_method_id) REFERENCES public.order_shipping_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_shipping order_shipping_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_shipping
    ADD CONSTRAINT order_shipping_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_summary order_summary_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_summary
    ADD CONSTRAINT order_summary_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_transaction order_transaction_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.order_transaction
    ADD CONSTRAINT order_transaction_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment_collection_payment_providers payment_collection_payment_providers_payment_col_aa276_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.payment_collection_payment_providers
    ADD CONSTRAINT payment_collection_payment_providers_payment_col_aa276_foreign FOREIGN KEY (payment_collection_id) REFERENCES public.payment_collection(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment_collection_payment_providers payment_collection_payment_providers_payment_pro_2d555_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.payment_collection_payment_providers
    ADD CONSTRAINT payment_collection_payment_providers_payment_pro_2d555_foreign FOREIGN KEY (payment_provider_id) REFERENCES public.payment_provider(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment payment_payment_collection_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_payment_collection_id_foreign FOREIGN KEY (payment_collection_id) REFERENCES public.payment_collection(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment_session payment_session_payment_collection_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.payment_session
    ADD CONSTRAINT payment_session_payment_collection_id_foreign FOREIGN KEY (payment_collection_id) REFERENCES public.payment_collection(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: price_list_rule price_list_rule_price_list_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.price_list_rule
    ADD CONSTRAINT price_list_rule_price_list_id_foreign FOREIGN KEY (price_list_id) REFERENCES public.price_list(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: price price_price_list_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT price_price_list_id_foreign FOREIGN KEY (price_list_id) REFERENCES public.price_list(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: price price_price_set_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT price_price_set_id_foreign FOREIGN KEY (price_set_id) REFERENCES public.price_set(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: price_rule price_rule_price_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.price_rule
    ADD CONSTRAINT price_rule_price_id_foreign FOREIGN KEY (price_id) REFERENCES public.price(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_category product_category_parent_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_category
    ADD CONSTRAINT product_category_parent_category_id_foreign FOREIGN KEY (parent_category_id) REFERENCES public.product_category(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_category_product product_category_product_product_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_category_product
    ADD CONSTRAINT product_category_product_product_category_id_foreign FOREIGN KEY (product_category_id) REFERENCES public.product_category(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_category_product product_category_product_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_category_product
    ADD CONSTRAINT product_category_product_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product product_collection_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_collection_id_foreign FOREIGN KEY (collection_id) REFERENCES public.product_collection(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: product_option product_option_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_option
    ADD CONSTRAINT product_option_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_option_value product_option_value_option_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_option_value
    ADD CONSTRAINT product_option_value_option_id_foreign FOREIGN KEY (option_id) REFERENCES public.product_option(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_tags product_tags_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_tags
    ADD CONSTRAINT product_tags_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_tags product_tags_product_tag_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_tags
    ADD CONSTRAINT product_tags_product_tag_id_foreign FOREIGN KEY (product_tag_id) REFERENCES public.product_tag(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product product_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_type_id_foreign FOREIGN KEY (type_id) REFERENCES public.product_type(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: product_variant_option product_variant_option_option_value_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_variant_option
    ADD CONSTRAINT product_variant_option_option_value_id_foreign FOREIGN KEY (option_value_id) REFERENCES public.product_option_value(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_variant_option product_variant_option_variant_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_variant_option
    ADD CONSTRAINT product_variant_option_variant_id_foreign FOREIGN KEY (variant_id) REFERENCES public.product_variant(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_variant product_variant_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_variant
    ADD CONSTRAINT product_variant_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_variant_product_image product_variant_product_image_image_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.product_variant_product_image
    ADD CONSTRAINT product_variant_product_image_image_id_foreign FOREIGN KEY (image_id) REFERENCES public.image(id) ON DELETE CASCADE;


--
-- Name: promotion_application_method promotion_application_method_promotion_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.promotion_application_method
    ADD CONSTRAINT promotion_application_method_promotion_id_foreign FOREIGN KEY (promotion_id) REFERENCES public.promotion(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion_campaign_budget promotion_campaign_budget_campaign_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.promotion_campaign_budget
    ADD CONSTRAINT promotion_campaign_budget_campaign_id_foreign FOREIGN KEY (campaign_id) REFERENCES public.promotion_campaign(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion_campaign_budget_usage promotion_campaign_budget_usage_budget_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.promotion_campaign_budget_usage
    ADD CONSTRAINT promotion_campaign_budget_usage_budget_id_foreign FOREIGN KEY (budget_id) REFERENCES public.promotion_campaign_budget(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion promotion_campaign_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_campaign_id_foreign FOREIGN KEY (campaign_id) REFERENCES public.promotion_campaign(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: promotion_promotion_rule promotion_promotion_rule_promotion_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.promotion_promotion_rule
    ADD CONSTRAINT promotion_promotion_rule_promotion_id_foreign FOREIGN KEY (promotion_id) REFERENCES public.promotion(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion_promotion_rule promotion_promotion_rule_promotion_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.promotion_promotion_rule
    ADD CONSTRAINT promotion_promotion_rule_promotion_rule_id_foreign FOREIGN KEY (promotion_rule_id) REFERENCES public.promotion_rule(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion_rule_value promotion_rule_value_promotion_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.promotion_rule_value
    ADD CONSTRAINT promotion_rule_value_promotion_rule_id_foreign FOREIGN KEY (promotion_rule_id) REFERENCES public.promotion_rule(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: provider_identity provider_identity_auth_identity_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.provider_identity
    ADD CONSTRAINT provider_identity_auth_identity_id_foreign FOREIGN KEY (auth_identity_id) REFERENCES public.auth_identity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: refund refund_payment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.refund
    ADD CONSTRAINT refund_payment_id_foreign FOREIGN KEY (payment_id) REFERENCES public.payment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: region_country region_country_region_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.region_country
    ADD CONSTRAINT region_country_region_id_foreign FOREIGN KEY (region_id) REFERENCES public.region(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: reservation_item reservation_item_inventory_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.reservation_item
    ADD CONSTRAINT reservation_item_inventory_item_id_foreign FOREIGN KEY (inventory_item_id) REFERENCES public.inventory_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: return_reason return_reason_parent_return_reason_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.return_reason
    ADD CONSTRAINT return_reason_parent_return_reason_id_foreign FOREIGN KEY (parent_return_reason_id) REFERENCES public.return_reason(id);


--
-- Name: service_zone service_zone_fulfillment_set_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.service_zone
    ADD CONSTRAINT service_zone_fulfillment_set_id_foreign FOREIGN KEY (fulfillment_set_id) REFERENCES public.fulfillment_set(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shipping_option shipping_option_provider_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_provider_id_foreign FOREIGN KEY (provider_id) REFERENCES public.fulfillment_provider(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: shipping_option_rule shipping_option_rule_shipping_option_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.shipping_option_rule
    ADD CONSTRAINT shipping_option_rule_shipping_option_id_foreign FOREIGN KEY (shipping_option_id) REFERENCES public.shipping_option(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shipping_option shipping_option_service_zone_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_service_zone_id_foreign FOREIGN KEY (service_zone_id) REFERENCES public.service_zone(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shipping_option shipping_option_shipping_option_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_shipping_option_type_id_foreign FOREIGN KEY (shipping_option_type_id) REFERENCES public.shipping_option_type(id) ON UPDATE CASCADE;


--
-- Name: shipping_option shipping_option_shipping_profile_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_shipping_profile_id_foreign FOREIGN KEY (shipping_profile_id) REFERENCES public.shipping_profile(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: stock_location stock_location_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.stock_location
    ADD CONSTRAINT stock_location_address_id_foreign FOREIGN KEY (address_id) REFERENCES public.stock_location_address(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: store_currency store_currency_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.store_currency
    ADD CONSTRAINT store_currency_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.store(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: store_locale store_locale_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.store_locale
    ADD CONSTRAINT store_locale_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.store(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: vendor_admin vendor_admin_vendor_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: princelulinda
--

ALTER TABLE ONLY public.vendor_admin
    ADD CONSTRAINT vendor_admin_vendor_id_foreign FOREIGN KEY (vendor_id) REFERENCES public.vendor(id) ON UPDATE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO princelulinda;


--
-- PostgreSQL database dump complete
--

\unrestrict 4SZiYWRVf0lyicvsELKP5YBanxBHv8ipobwyzzZdSuVNk2hqh2kKBeDvnQbeLzU

