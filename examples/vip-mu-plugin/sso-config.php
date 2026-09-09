<?php
/**
 * VIP mu-plugin: SAML SSO via Human Made wp-simple-saml pattern.
 *
 * Copy to: client-mu-plugins/sso-config.php (or your VIP integration plugin).
 * Store IdP metadata XML in .private/sso/ (not web-accessible).
 *
 * Switch IdP: set VIP_SAML_IDP to "okta" or "keycloak" via environment variable.
 */

declare( strict_types = 1 );

/**
 * Active IdP: keycloak | okta
 */
function dixon_sso_active_idp(): string {
	$idp = getenv( 'VIP_SAML_IDP' ) ?: 'okta';
	return in_array( $idp, [ 'keycloak', 'okta' ], true ) ? $idp : 'okta';
}

/**
 * Path to IdP metadata XML on the VIP filesystem.
 */
function dixon_sso_metadata_path(): string {
	$idp = dixon_sso_active_idp();
	return ABSPATH . '.private/sso/' . $idp . '-idp.xml';
}

add_filter(
	'wpsimplesaml_idp_metadata_xml_path',
	function (): string {
		return dixon_sso_metadata_path();
	}
);

add_filter(
	'wpsimplesaml_attribute_mapping',
	function (): array {
		return [
			'user_login' => 'uid',
			'user_email' => 'email',
			'first_name' => 'givenName',
			'last_name'  => 'familyName',
		];
	}
);

/**
 * Allowlist: only your email may SSO in. Fail closed — no JIT for strangers.
 */
add_filter(
	'wpsimplesaml_match_user',
	function ( $user, string $email, array $saml_attributes ) {
		unset( $saml_attributes );
		$allowed = getenv( 'VIP_SAML_ALLOWED_EMAIL' ) ?: '';
		if ( $allowed && strcasecmp( $email, $allowed ) !== 0 ) {
			return null;
		}
		return $user;
	},
	10,
	3
);

add_filter(
	'wpsimplesaml_user_data',
	function ( array $user_data ): array {
		$allowed = getenv( 'VIP_SAML_ALLOWED_EMAIL' ) ?: '';
		if ( $allowed && isset( $user_data['user_email'] ) && strcasecmp( $user_data['user_email'], $allowed ) !== 0 ) {
			wp_die( esc_html__( 'SSO is restricted to authorized users.', 'dixon-sso' ), 403 );
		}
		return $user_data;
	}
);
