/*
 * Vault configuration. See: https://www.vaultproject.io/docs/configuration
 */

storage "file" {
    path = "/srv/lib/vault"
}

listener "tcp" {
    /*
     * By default Vault listens on localhost only.
     * Make sure to enable TLS support otherwise.
     */
    tls_disable = 1
    address = 127.0.0.1:8200
}

log_level = "info"
log_format = "standard"
api_addr = "https://127.0.0.1:8200"

