# Remove this
# Optionally copy the rendered files locally for debugging purposes
resource local_file replicated-conf {
  filename = "./.terraform/replicated-conf.json"
  content  = module.configs.replicated_config
}

resource local_file replicated-tfe-conf {
  filename = "./.terraform/replicated-tfe-conf.json"
  content  = module.configs.replicated_tfe_config
}

resource local_file startup_script {
  filename = "./.terraform/startup_script.sh"
  content  = module.configs.startup_script
}
