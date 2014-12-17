<?php

namespace Build2be\Drupal\Rest\Utility;

use Twig_Autoloader;
use Twig_Loader_Filesystem;
use Twig_Environment;

/**
 * Class TwigToJson
 * @package Build2be\Drupal\Rest\Utility
 *
 *
 */
class TwigToJson
{
    function randomString($length)
    {
        return join('', array_map(function () {
            return substr('0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ   ', rand(0, 64), 1);
        }, range(1, $length)));
    }

    public function __construct()
    {
        $this->init();
    }

    public function init()
    {
        Twig_Autoloader::register();

        $path = array('src/templates');
        if (is_dir('templ')) {
            $path[] = 'templates';
        }
        $this->_loader = new Twig_Loader_Filesystem($path);
        $this->_twig = new Twig_Environment($this->_loader, array(//  'cache' => '/tmp/twig',
        ));
    }

    public function render($template, $values)
    {
        return $this->_twig->render($template . '.json.twig', $values);
    }

    public function post($values, $encoding = 'json')
    {
        $type = $values['type'];
        $bundle = $values['bundle'] ?: null;
        $template = $encoding . '-' . $type . (isset($bundle) ? '-' . $bundle : '');
        echo "Template: $template" . PHP_EOL;
        return $this->render($template, $values);
    }

}