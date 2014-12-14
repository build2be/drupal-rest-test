<?php

//namespace Drupal\Rest\Connector;

use Guzzle\Http\Client;

class DrupalConnector
{
    protected $_context;
    protected $_twig;
    protected $_loader;
    protected $_debug;
    protected $_xdebug;
    protected $_contentType;

    public function setContext($context)
    {
        $this->_context = $context;
    }

    function post($url, $headers, $payload)
    {
        return $this->http('POST', $url, $headers, $payload);
    }

    function patch($url, $headers, $payload)
    {
        return $this->http('PATCH', $url, $headers, $payload);
    }

    function delete($url, $headers, $payload)
    {
        return $this->http('DELETE', $url, $headers, $payload);
    }

    function http($method, $url, $headers = array(), $payload)
    {
        $server = $this->_context['url'];
        $client = new Client($server);

        if (!isset($headers['Content-type'])) {
            $headers['Content-type'] = $this->getContentType();
        }

        $debug = $this->getXDebug();
        if ($debug) {
            $url .= '?' . $debug;
        }
        if ($this->getDebug() > 1) {
            echo '--------------------' . PHP_EOL;
            echo $method . ' /' . $url . PHP_EOL;
            foreach ($headers as $key => $value) {
                echo $key . ': ' . $value . PHP_EOL;
            }
            echo PHP_EOL;
            echo json_encode(json_decode($payload, true), JSON_PRETTY_PRINT) . PHP_EOL;
            echo '--------------------' . PHP_EOL;
        }
        try {
            $response = $client->createRequest($method, $url, $headers, $payload)
                ->setAuth($this->_context['username'], $this->_context['password'])
                ->send();
        } catch (\Guzzle\Http\Exception\ClientErrorResponseException $e) {
            $response = $e->getResponse();
        } catch (\Guzzle\Http\Exception\ServerErrorResponseException $e) {
            $response = $e->getResponse();
        }
        if ($this->getDebug() > 0) {
            echo 'Status Code: ' . $response->getStatusCode() . PHP_EOL;
            foreach ($response->getHeaders() as $key => $value) {
                echo $key . ': ' . $value . PHP_EOL;
            }
            echo PHP_EOL;
            $contentType = $response->getContentType();
            if (strpos($contentType, 'json') !== false) {
                echo json_encode(json_decode($response->getBody(true), true), JSON_PRETTY_PRINT) . PHP_EOL;
            } else {
                echo $response->getBody(true);
            }
        }
        return $response;
    }

    function getXDebug()
    {
        if ($this->_xdebug) {
            return 'XDEBUG_SESSION_START=' . $this->_xdebug;
        }
        return '';
    }

    function getDebug()
    {
        return $this->_debug;
    }

    function setDebug($debug)
    {
        $this->_debug = $debug;
    }

    function setXDebug($value)
    {
        $this->_xdebug = $value;
    }

    function getContentType()
    {
        return $this->_contentType;
    }

    function setContentType($contentType)
    {
        $this->_contentType = $contentType;
    }
}
