###
# Copyright (C) 2014-2015 Taiga Agile LLC <taiga@taiga.io>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: joy-ride.directive.coffee
###

taiga = @.taiga

JoyRideDirective = ($rootScope, currentUserService, joyRideService, $location) ->
    link = (scope, el, attrs, ctrl) ->
        unsuscribe = null
        intro = introJs()

        #Todo: translate
        intro.setOptions({
            exitOnEsc: false,
            exitOnOverlayClick: false,
            showStepNumbers: false,
            nextLabel: 'Next &rarr;',
            prevLabel: '&larr; Back',
            skipLabel: 'Skip',
            doneLabel: 'Done',
            disableInteraction: true
        })

        intro.oncomplete () ->
            $('html,body').scrollTop(0)

        intro.onexit () ->
            currentUserService.disableJoyRide()

        initJoyrRide = (next, config) ->
            if !config[next.joyride]
                return

            intro.setOption('steps', joyRideService.get(next.joyride))
            intro.start()

        $rootScope.$on '$routeChangeSuccess',  (event, next) ->
            if !next.joyride || !currentUserService.isAuthenticated()
                intro.exit()
                unsuscribe() if unsuscribe
                return


            intro.oncomplete () ->
                currentUserService.disableJoyRide(next.joyride)

            if next.loader
                unsuscribe = $rootScope.$on 'loader:end',  () ->
                    currentUserService.loadJoyRideConfig()
                        .then (config) -> initJoyrRide(next, config)

                    unsuscribe()
            else
                currentUserService.loadJoyRideConfig()
                    .then (config) -> initJoyrRide(next, config)

    return {
        scope: {},
        link: link
    }

JoyRideDirective.$inject = [
    "$rootScope",
    "tgCurrentUserService",
    "tgJoyRideService",
    "$location"
]

angular.module("taigaComponents").directive("tgJoyRide", JoyRideDirective)
