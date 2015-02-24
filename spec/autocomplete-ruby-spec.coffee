AutocompleteRuby = require '../lib/autocomplete-ruby'

describe "AutocompleteRuby", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('autocomplete-ruby')

  describe "autocomplete-ruby", ->
    it "contains spec with an expectation", ->
      expect(true).toBe(true)
