AutocompleteRuby = require '../lib/autocomplete-ruby'

describe "AutocompleteRuby", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('autocomplete-ruby')
    waitsForPromise -> activationPromise

  describe "autocomplete-ruby", ->
    it 'Starts and stops rsense', ->
      rsenseProvider = AutocompleteRuby.rsenseProvider
      rsenseClient = rsenseProvider.rsenseClient

      expect(rsenseClient.rsenseStarted).toBe(false)

      # The first request for autocompletion starts rsense
      rsenseProvider.requestHandler()
      expect(rsenseClient.rsenseStarted).toBe(true)

      rsenseClient.stopRsense()
      expect(rsenseClient.rsenseStarted).toBe(true)
