'use strict';

/* Services */

// ToDo: wire this up to a backend like firebase or parse

var cartoonistServices = angular.module('theApp.services', []);

// register service called DataProviderService
cartoonistServices.factory('DataProviderService', ['$rootScope', function($rootScope){

    var MODEL_KEY = 'model';
    //localStorage.clear();

    var service = {

        // an array of localstorage keys that point to story values
        storyKeys:[],
        STORY_KEYS_KEY: 'STORY_KEYS_KEY',

        // the selected story index within the keys array
        SELECTED_STORY_INDEX_KEY : 'SELECTED_STORY_INDEX_KEY',
        selectedStoryKeyIndex:0,

        // selected story value
        modelkey: null,
        model: null,

        StoryByKey: function(key){
            var story = localStorage.getItem(key);
            if (story==null||story==undefined){
                return null;
            }
            return angular.fromJson(story);
        },

        StoryTitleByKey: function(key){
            var story = service.StoryByKey(key);
            if (story==null) {
                return 'Null';
            }
            return story.title;
        },

        SaveState: function () {
            //localStorage.setItem(MODEL_KEY, angular.toJson(service.model));
            localStorage.setItem(service.STORY_KEYS_KEY, angular.toJson(service.storyKeys));
            localStorage.setItem(service.SELECTED_STORY_INDEX_KEY, service.selectedStoryKeyIndex);
            localStorage.setItem(service.modelkey, angular.toJson(service.model));
        },

        RestoreState: function () {

            // retrieve list of story handles
            service.storyKeys = localStorage.getItem(service.STORY_KEYS_KEY);
            if (service.storyKeys==null||service.storyKeys==undefined){
                console.log('storykeys undefined, so write first time');
                service.storyKeys = [];
                localStorage.setItem(service.STORY_KEYS_KEY, angular.toJson(service.storyKeys));
            } else {
                service.storyKeys = angular.fromJson(service.storyKeys);
            }

            // retrieve last known story index
            service.selectedStoryKeyIndex = localStorage.getItem(service.SELECTED_STORY_INDEX_KEY);
            if (service.selectedStoryKeyIndex==null||service.selectedStoryKeyIndex==undefined){
                console.log('selectedstoryindex undefined, so write first time');
                service.selectedStoryKeyIndex = 0;
                localStorage.setItem(service.SELECTED_STORY_INDEX_KEY, service.selectedStoryKeyIndex);
            }

            // retrieve story handle for last known index
            var storyKey;
            if (service.storyKeys.length>0){
                storyKey = service.storyKeys[service.selectedStoryKeyIndex];
                if (storyKey==null||storyKey==undefined){
                    console.log('storykey undefined, so write first time');
                    storyKey = uniqueid();
                    service.storyKeys.push(storyKey);
                    localStorage.setItem(service.STORY_KEYS_KEY, angular.toJson(service.storyKeys));

                }
            } else {
                console.log('storykeys empty, so write first time');
                storyKey = uniqueid();
                service.storyKeys.push(storyKey);
                localStorage.setItem(service.STORY_KEYS_KEY, angular.toJson(service.storyKeys));
            }
            service.modelkey = storyKey;

            // retrieve last known story
            var story = localStorage.getItem(storyKey);
            if (story==null||story==undefined){
                console.log('story undefined, so write first time');
                // put a sample story in to start with
                story = {"type":"sequence","nodes":[{"type":"frame","celltype":"nocaption","image":"saw-24","caption":"Gigantic Shadow Things!\nby \nDavid Lu","id":"L8V8JNTHUJYRE2X7VODR1XA92FKDQD3A","parentid":"IQ0SR1GBKILSGP96XG44GVS38UKB63HT"},{"type":"frame","celltype":"wireframe","image":null,"caption":"This is a choose-your-own-adventure book. Your choices influence the drawing style.","id":"Y6QRAU85YSPWE9D7WW4F73FCDLS6YS54","parentid":"IQ0SR1GBKILSGP96XG44GVS38UKB63HT"},{"type":"frame","celltype":"wireframe","image":null,"caption":"On the next panel, you can make your first choice. Ready?","id":"KF7F4H72VKBJGB9218AOV71EXFTFRVY9","parentid":"IQ0SR1GBKILSGP96XG44GVS38UKB63HT"},{"type":"joint","selected":1,"children":[{"type":"sequence","nodes":[{"type":"frame","celltype":"caption","image":"saw-13","caption":"Daddy, why is your *shadow man* so gigantic?","id":"BJW1P52RIC5WV7Q1FX1KM90WS49VUJIV","parentid":"DE8DYIFKWCR6EVP3P07WMY7CGTKVWGXJ"},{"type":"frame","celltype":"caption","image":"saw-14","caption":"Well, son, as we age, we carry more of the weight of the world on our shoulders. It's sometimes too much for our own shoulders to carry...","id":"JD4XCYDRLTPVXS076SDGCTEB6AKC8U5W","parentid":"DE8DYIFKWCR6EVP3P07WMY7CGTKVWGXJ"},{"type":"frame","celltype":"caption","image":"saw-15","caption":"...so our shadows do this for us!","id":"L1QA616ORKCN28JG04EI2V0TUI4VXBYD","parentid":"DE8DYIFKWCR6EVP3P07WMY7CGTKVWGXJ"},{"type":"frame","celltype":"caption","image":"saw-16","caption":"When your sister was your age, her shadow was just as big as she was...","id":"LFYVQ6705PIPEEJ9K2MY24P3HDLQYL8P","parentid":"DE8DYIFKWCR6EVP3P07WMY7CGTKVWGXJ"},{"type":"frame","celltype":"caption","image":"saw-17","caption":"Now, her shadow is as big as the biggest cloud!","id":"PG4I3YI99MWJ0UIJ0UYSM1D83W1GT0CT","parentid":"DE8DYIFKWCR6EVP3P07WMY7CGTKVWGXJ"},{"type":"frame","celltype":"nocaption","image":"saw-18","caption":"empty","id":"UAHQ5FRJYIWPYBN3RWOMMHJNNK2UPR7Q","parentid":"DE8DYIFKWCR6EVP3P07WMY7CGTKVWGXJ"},{"type":"frame","celltype":"caption","image":"saw-19","caption":"Daddy, do animals have shadow giants too?","id":"EQXC3AY2YFHTDUYYDRP97POUFOHOKGRF","parentid":"DE8DYIFKWCR6EVP3P07WMY7CGTKVWGXJ"},{"type":"frame","celltype":"caption","image":"saw-20","caption":"No, son... Shadow giants are particular to humans! Animals have to make do with their regular, plain type shadow things!","id":"KEPSNWR67C8FKC19HQ6JB9G0OYN6QXJV","parentid":"DE8DYIFKWCR6EVP3P07WMY7CGTKVWGXJ"},{"type":"frame","celltype":"caption","image":"saw-21","caption":"What about reflections, daddy?","id":"NBREWXA2645I7LRYPP9GLD2UG2V1WHFL","parentid":"DE8DYIFKWCR6EVP3P07WMY7CGTKVWGXJ"},{"type":"frame","celltype":"caption","image":"saw-22","caption":"No, son... Reflections are just reflections. However, in the movies, sometimes you see people pretending to be shadows!","id":"HK9K3SNC85Y14WPVU3U529XLRBLQB8I7","parentid":"DE8DYIFKWCR6EVP3P07WMY7CGTKVWGXJ"},{"type":"frame","celltype":"caption","image":"saw-23","caption":"My greatest hope for you, son, is that you find a nice lady to be your very own shadow one day!","id":"SM0XQHKW3TB43PL3KF4IP1VVY6D1BK8P","parentid":"DE8DYIFKWCR6EVP3P07WMY7CGTKVWGXJ"},{"type":"frame","celltype":"nocaption","image":"saw-04","caption":"The End","id":"RCXV2NDBOI0XO6829QYNFVCWWOQIFQMG","parentid":"DE8DYIFKWCR6EVP3P07WMY7CGTKVWGXJ"}],"image":"saw-13","caption":"blind contour","id":"DE8DYIFKWCR6EVP3P07WMY7CGTKVWGXJ","parentid":"H33YHJ08QF4BNFE02JB55BVMJ5OMO8WT"},{"type":"sequence","nodes":[{"type":"frame","celltype":"caption","image":"saw-01","caption":"Daddy, why is your *shadow man* so gigantic?","id":"U5S1NGXKPA9E9JR4YORE67LAVSJ4TFKK","parentid":"M40S1FCMWPO53KKNJIEGORP0YYA0OK7Y"},{"type":"frame","celltype":"caption","image":"saw-02","caption":"Well, son, as we age, we carry more of the weight of the world on our shoulders. It's sometimes too much for our own shoulders to carry...","id":"XFVYOUNULDM9L866A4O89BA4JXXXWB1J","parentid":"M40S1FCMWPO53KKNJIEGORP0YYA0OK7Y"},{"type":"frame","celltype":"caption","image":"saw-03","caption":"...so our shadows do this for us!","id":"ANATOF0XEAWIAK68SIX0XD7WYGU04FD6","parentid":"M40S1FCMWPO53KKNJIEGORP0YYA0OK7Y"},{"type":"frame","celltype":"caption","image":"saw-05","caption":"When your sister was your age, her shadow was just as big as she was...","id":"IAE3SSO66FE89DMP57DKA8S1LD20SQRV","parentid":"M40S1FCMWPO53KKNJIEGORP0YYA0OK7Y"},{"type":"frame","celltype":"caption","image":"saw-06","caption":"But now her shadow giant is as big as the biggest cloud!","id":"OM7JGGNHDSD612X6EK7232AJ59GTG378","parentid":"M40S1FCMWPO53KKNJIEGORP0YYA0OK7Y"},{"type":"frame","celltype":"nocaption","image":"saw-07","caption":"","id":"M8S007S085K5FYEKC8VYAQVN2CVTRTT4","parentid":"M40S1FCMWPO53KKNJIEGORP0YYA0OK7Y"},{"type":"frame","celltype":"caption","image":"saw-08","caption":"Daddy, do animals have shadow giants too?","id":"WRJ952U2AJTKSYDINTRGDYLW9JPWSY7T","parentid":"M40S1FCMWPO53KKNJIEGORP0YYA0OK7Y"},{"type":"frame","celltype":"caption","image":"saw-09","caption":"No, son... Shadow giants are particular to humans! Animals have to make do with their regular, plain type shadow things!","id":"XGU94PTCMB6QIS7NMJKSRQPG1I9T9MYA","parentid":"M40S1FCMWPO53KKNJIEGORP0YYA0OK7Y"},{"type":"frame","celltype":"caption","image":"saw-10","caption":"What about reflections, daddy?","id":"PFQ3WXB4Y2E5T9M264WDPVR3S8Y33BDD","parentid":"M40S1FCMWPO53KKNJIEGORP0YYA0OK7Y"},{"type":"frame","celltype":"caption","image":"saw-11","caption":"No, son... Reflections are just reflections. However, in the movies, sometimes you see people pretending to be shadows!","id":"XBD2AOTWT0T0HXBC9XEAGBQM2OD2KY8R","parentid":"M40S1FCMWPO53KKNJIEGORP0YYA0OK7Y"},{"type":"frame","celltype":"caption","image":"saw-12","caption":"My greatest hope for you, son, is that you find a nice lady to be your very own shadow one day!","id":"SACWCMQ9LTUI2X4HT2L9CISQMAPKHHMV","parentid":"M40S1FCMWPO53KKNJIEGORP0YYA0OK7Y"},{"type":"frame","celltype":"nocaption","image":"saw-04","caption":"The End","id":"LU78CQ9HOFB08IJXAC0YAB7USPJ2ADVU","parentid":"M40S1FCMWPO53KKNJIEGORP0YYA0OK7Y"}],"image":"saw-01","caption":"rotoscoped","id":"M40S1FCMWPO53KKNJIEGORP0YYA0OK7Y","parentid":"H33YHJ08QF4BNFE02JB55BVMJ5OMO8WT"}],"id":"H33YHJ08QF4BNFE02JB55BVMJ5OMO8WT","parentid":"IQ0SR1GBKILSGP96XG44GVS38UKB63HT"}],"image":null,"caption":"r","id":"IQ0SR1GBKILSGP96XG44GVS38UKB63HT","title":"Gigantic Shadow Things, Yeah!"};
                story.title = 'Gigantic Shadow Things';
                localStorage.setItem(storyKey, angular.toJson(story));
            } else {
                story = angular.fromJson(story);
            }
            service.model = story;

            // make a dictionary lookup of models by id (for easy reference)
            // also, this prevents cyclical json structures (which is illegal)
            idlookup = [];
            parseAndIndex(service.model);

            console.log(service.storyKeys);
        },

        NewEmpty:function(){
            console.log('newempty');
            var tree = makeSequence();
            var node = makeNode('empty');
            addNodeToSequence(node, tree);
            tree.title = 'empty';
            service.AddTreeToStories(tree);
        },

        NewGenerated:function(){
            console.log('newgen');
            var tree = makeSampleTree();
            tree.title = 'generated';
            service.AddTreeToStories(tree);
        },

        NewDuplicate:function(){
            // construct a duplicate as follows:
            // - make a json string
            // - turn json back into an object
            var json = angular.toJson(service.model);
            var dupe = angular.fromJson(json);
            dupe.title += ', copy';
            service.AddTreeToStories(dupe);
        },

        AddTreeToStories:function(tree){

            // 1: store the story in localstorage
            var key = uniqueid();
            var json = angular.toJson(tree);
            localStorage.setItem(key, json);

            // 2: store the key in localstorage
            service.storyKeys.push(key);
            localStorage.setItem(service.STORY_KEYS_KEY, angular.toJson(service.storyKeys));

            // 3: change the current story pointers
            service.selectedStoryKeyIndex = service.storyKeys.length-1;
            localStorage.setItem(service.SELECTED_STORY_INDEX_KEY, service.selectedStoryKeyIndex);
            service.model = tree;
            service.modelkey = key;

            idlookup = [];
            parseAndIndex(service.model);

            $rootScope.$broadcast('SELECTED_MODEL_UPDATED', null);
        },

        SelectIndex:function(index){
            console.log('SelectIndex');

            // update the selected index
            service.selectedStoryKeyIndex = index;
            localStorage.setItem(service.SELECTED_STORY_INDEX_KEY, service.selectedStoryKeyIndex);

            // update the selected key
            var storyKey = service.storyKeys[service.selectedStoryKeyIndex];
            service.modelkey = storyKey;

            // update the selected model
            var story = localStorage.getItem(storyKey);
            story = angular.fromJson(story);
            service.model = story;

            idlookup = [];
            parseAndIndex(service.model);


            $rootScope.$broadcast('SELECTED_MODEL_UPDATED', null);
        },

        RemoveStoryAtIndex:function(index){
            console.log('remove '+index);
            if (service.storyKeys.length<2) return;

            // remove value from values
            //localStorage.removeItem(service.modelkey);

            // remove key from keys
            service.storyKeys.splice(index, 1);
            localStorage.setItem(service.STORY_KEYS_KEY, angular.toJson(service.storyKeys));

            // update selected key, just set to 0 to be safe
            //service.selectedStoryKeyIndex = 0;
            if (service.selectedStoryKeyIndex>service.storyKeys.length-1){
                service.selectedStoryKeyIndex = service.storyKeys.length-1;
            }
            localStorage.setItem(service.SELECTED_STORY_INDEX_KEY, service.selectedStoryKeyIndex);

            service.modelkey = service.storyKeys[service.selectedStoryKeyIndex];
            service.model = angular.fromJson(localStorage.getItem(service.modelkey));

            idlookup = [];
            parseAndIndex(service.model);

            $rootScope.$broadcast('SELECTED_MODEL_UPDATED', null);
        }
    };
    service.RestoreState();
    return service;
}]);
