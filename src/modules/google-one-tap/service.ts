import {
  AuthenticationInput,
  AuthenticationResponse,
  AuthIdentityProviderService,
  Logger,
} from "@medusajs/framework/types"
import { AbstractAuthModuleProvider, MedusaError } from "@medusajs/framework/utils"
import { OAuth2Client } from "google-auth-library"

type InjectedDependencies = {
  logger: Logger
}

type Options = {
  clientId: string
}

/**
 * Authenticates users from Google One Tap / Sign In With Google.
 * Unlike `@medusajs/medusa/auth-google` (authorization code flow, where the
 * id_token comes straight from Google's token endpoint and is trusted as-is),
 * here the client hands us the id_token directly, so it MUST be verified
 * against Google's signing keys before we trust its payload.
 */
export class GoogleOneTapAuthService extends AbstractAuthModuleProvider {
  static identifier = "google-onetap"
  static DISPLAY_NAME = "Google One Tap Authentication"

  protected config_: Options
  protected logger_: Logger
  protected client_: OAuth2Client

  static validateOptions(options: Options) {
    if (!options.clientId) {
      throw new MedusaError(MedusaError.Types.INVALID_DATA, "Google One Tap clientId is required")
    }
  }

  constructor({ logger }: InjectedDependencies, options: Options) {
    // @ts-ignore
    super(...arguments)
    this.config_ = options
    this.logger_ = logger
    this.client_ = new OAuth2Client(options.clientId)
  }

  async authenticate(
    data: AuthenticationInput,
    authIdentityService: AuthIdentityProviderService
  ): Promise<AuthenticationResponse> {
    const credential = data.body?.credential

    if (!credential) {
      return { success: false, error: "No credential provided" }
    }

    let payload
    try {
      const ticket = await this.client_.verifyIdToken({
        idToken: credential,
        audience: this.config_.clientId,
      })
      payload = ticket.getPayload()
    } catch (error) {
      return { success: false, error: `Invalid Google credential: ${error.message}` }
    }

    if (!payload) {
      return { success: false, error: "Invalid Google credential" }
    }

    if (!payload.email_verified) {
      return { success: false, error: "Email not verified, cannot proceed with authentication" }
    }

    const entity_id = payload.sub
    const userMetadata = {
      name: payload.name,
      email: payload.email,
      picture: payload.picture,
      given_name: payload.given_name,
      family_name: payload.family_name,
    }

    let authIdentity
    try {
      authIdentity = await authIdentityService.retrieve({ entity_id })
    } catch (error) {
      if (error.type === MedusaError.Types.NOT_FOUND) {
        authIdentity = await authIdentityService.create({
          entity_id,
          user_metadata: userMetadata,
        })
      } else {
        return { success: false, error: error.message }
      }
    }

    return { success: true, authIdentity }
  }
}

export default GoogleOneTapAuthService
