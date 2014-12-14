<?php

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

        $this->_loader = new Twig_Loader_Filesystem('templates');
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
        return $this->render($template, $values);
    }

}