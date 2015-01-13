<?php

namespace Build2be\Drupal\Rest;

use Guzzle\Http\Client;

class DrupalConnector
{
    protected $_context;
    protected $_twig;
    protected $_loader;
    protected $_debug;
    protected $_xdebug;
    protected $_contentType;
    protected $_accept = 'application/json';

    /**
     * @param array $context
     *   $context = array(
     *     'url' => 'http://example.com',
     *     'username' => 'restuser',
     *     'password' => 'restpassword',
     *   );
     */
    public function setContext(array $context)
    {
        $this->_context = $context;
    }

    function get($url, $headers)
    {
        return $this->http('GET', $url, $headers, null);
    }

    function post($url, $headers, $body)
    {
        return $this->http('POST', $url, $headers, $body);
    }

    function patch($url, $headers, $body)
    {
        return $this->http('PATCH', $url, $headers, $body);
    }

    function delete($url, $headers = null, $body = null)
    {
        return $this->http('DELETE', $url, $headers, $body);
    }

    function http($method, $url, $headers = array(), $body)
    {
        $server = $this->_context['url'];
        $client = new Client($server);

        if (!isset($headers['Content-type'])) {
            $headers['Content-type'] = $this->getContentType();
        }
        if (!isset($headers['Accept'])) {
            $headers['Accept'] = $this->getAccept();
        }

        $debug = $this->getXDebug();
        if ($debug) {
            if (strpos($url, '?') === FALSE) {
                $url .= '?';
            }
            else {
                $url .= '&';
            }
            $url .= $debug;
        }
        if ($this->getDebug() > 1) {
            echo '====================' . PHP_EOL;
            echo $method . ' /' . $url . PHP_EOL;
            foreach ($headers as $key => $value) {
                echo $key . ': ' . $value . PHP_EOL;
            }
            echo PHP_EOL;
        }
        $json =json_decode($body, true);
        if ($this->getDebug() > 1) {
            echo '--------------------' . PHP_EOL;
            if ($json === NULL) {
                echo "ERROR : Invalid JSON" . PHP_EOL;;
                echo '--------------------' . PHP_EOL;
                echo $body . PHP_EOL;
            }
            else {
                echo json_encode($json) . PHP_EOL;
                echo '--------------------' . PHP_EOL;
                echo json_encode($json, JSON_PRETTY_PRINT) . PHP_EOL;
            }
            echo '--------------------' . PHP_EOL;
        }
        try {
            $response = $client->createRequest($method, $url, $headers, $body)
                ->setAuth($this->_context['username'], $this->_context['password'])
                ->send();
        } catch (\Guzzle\Http\Exception\ClientErrorResponseException $e) {
            $response = $e->getResponse();
        } catch (\Guzzle\Http\Exception\ServerErrorResponseException $e) {
            $response = $e->getResponse();
        }
        if ($this->getDebug() > 0) {
            echo "Status: " . $response->getStatusCode() . ": " . $response->getReasonPhrase() . PHP_EOL;
            foreach ($response->getHeaders() as $key => $value) {
                echo $key . ': ' . $value . PHP_EOL;
            }
            echo PHP_EOL;
            $contentType = $response->getContentType();
            $body = $response->getBody(true);
            if ((strpos($contentType, 'application/json') !== false) || (strpos($contentType, 'application/hal+json') !== false)) {
                echo json_encode(json_decode($body, true), JSON_PRETTY_PRINT) . PHP_EOL;
            }
            echo "------ RAW ------" . PHP_EOL;
            echo $body . PHP_EOL;
            echo "------ /RAW -----" . PHP_EOL;
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

    function getAccept()
    {
        return $this->_accept;
    }

    function setAccept($accept)
    {
        $this->_accept = $accept;
    }
}
