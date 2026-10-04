Feature: Pruebas de regresión

  Background:
    * def generarCelular =
    """
    function() {
      return Math.floor(100000000 + Math.random() * 900000000);
    }
    """

    * def emisor =
    """
    {
      "phone": "#(generarCelular())",
      "fullName": "Emisor",
      "email": "emisor@test.com",
      "pin": "123456"
    }
    """

    * def receptor =
    """
    {
      "phone": "#(generarCelular())",
      "fullName": "Receptor",
      "email": "receptor@test.com",
      "pin": "654321"
    }
    """

  Scenario Outline: Registro de usuarios
    * def usuario = <usuario>

    Given url 'http://134.209.211.10:4001'
    And path '/auth/v1/register'
    And header x-channel = 'POSTMAN'
    And request usuario
    When method post
    Then status 201
    * def idUsuario = response.user.id

    Given url 'http://134.209.211.10:4001'
    And path '/auth/v1/login'
    And header x-channel = 'POSTMAN'
    And request
    """
    {
      "phone": "#(usuario.phone)",
      "pin": "#(usuario.pin)"
    }
    """
    When method post
    Then status 200
    * def token = response.token

    Given url 'http://134.209.211.10:4002'
    And path '/wallet/v1/deposit'
    And header x-channel = 'POSTMAN'
    And header Authorization = 'Bearer ' + token
    And request
    """
    {
      "amount": 500
    }
    """
    When method post
    Then status 200
    And match response == { success: true, newBalance: 500 }
    Examples:
      | usuario |
      | emisor |
      | receptor |


