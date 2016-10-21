AutocompleteRuby = require '../lib/autocomplete-ruby'

describe "AutocompleteRuby", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    atom.config.set('autocomplete-plus.enableAutoActivation', true)
    waitsForPromise ->
      Promise.all [
        atom.workspace.open('sample.js').then (e) ->
          editor = e
          editorView = atom.views.getView(editor)
        atom.packages.activatePackage('autocomplete-plus')
        atom.packages.activatePackage('autocomplete-ruby')
      ]

  describe "autocomplete-ruby", ->
    it 'Starts and stops rsense', ->
      rsenseProvider = AutocompleteRuby.rsenseProvider
      rsenseClient = rsenseProvider.rsenseClient

      expect(rsenseClient.rsenseStarted).toBe(false)

      # The first request for autocompletion starts rsense
      rsenseProvider.getSuggestions()
      expect(rsenseClient.rsenseStarted).toBe(true)

      rsenseClient.stopRsense()
      expect(rsenseClient.rsenseStarted).toBe(true)
